import credits.aleo;
import employer_agreement.aleo;
import process_tax_compliance.aleo;
import weekly_payroll_pool.aleo;
import pncw_payroll.aleo;
import pniw_payroll.aleo;
import subdao_reserve.aleo;

program main.aleo {
    mapping worker_category: [u8; 32] => u8;
    mapping worker_zpass_hash: [u8; 32] => [u8; 64];
    mapping worker_type: [u8; 32] => u8;

    const WORKER_CATEGORY_FT: u8 = 1u8;
    const WORKER_CATEGORY_CONTRACT: u8 = 2u8;
    const PAYROLL_FUNCTION_PNCW: u8 = 10u8;
    const PAYROLL_FUNCTION_PNIW: u8 = 20u8;

    function hash_worker_ans(worker_name: bytes, height: u64) -> [u8; 32] {
        return hash_blake3(worker_name ++ height as bytes); // Verify hash_blake3 support in 2.4.1
    }

    function hash_subdao_ans(subdao_name: bytes, height: u64) -> [u8; 32] {
        return hash_blake3(subdao_name ++ height as bytes); // Verify hash_blake3 support
    }

    function hash_zpass(worker_ans: [u8; 32], secret: bytes) -> [u8; 64] {
        let part1: [u8; 32] = hash_blake3(worker_ans ++ secret);
        let part2: [u8; 32] = hash_blake3(worker_ans ++ secret ++ b":part2");
        return part1 ++ part2;
    }

    function worker_exists(hashed_worker: [u8; 32]) -> bool {
        return worker_category.contains(hashed_worker);
    }

    function get_worker_type(hashed_worker: [u8; 32]) -> u8 {
        return worker_type.get_or_use(hashed_worker, 0u8);
    }

    function get_employer_ans(caller: [u8; 32]) -> [u8; 32] {
        return [0u8; 32]; // Simplified for MVP
    }

    async transition register_worker(worker_name: bytes, category: u8, worker_type_flag: u8, zpass_secret: bytes) -> bool {
        assert(category == WORKER_CATEGORY_FT || category == WORKER_CATEGORY_CONTRACT);
        assert(worker_type_flag == PAYROLL_FUNCTION_PNCW || worker_type_flag == PAYROLL_FUNCTION_PNIW);

        let height: u64 = block.height;
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, height);
        assert(!worker_exists(hashed_worker)); // Prevent overwrites
        let zpass_hash: [u8; 64] = hash_zpass(hashed_worker, zpass_secret);

        worker_category.set(hashed_worker, category);
        worker_type.set(hashed_worker, worker_type_flag);
        worker_zpass_hash.set(hashed_worker, zpass_hash);

        return true;
    }

    async transition pay_worker(worker_name: bytes, subdao_name: bytes, amount: u64, zpass_secret: bytes) -> bool {
        assert(amount > 0u64);

        let height: u64 = block.height;
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, height);
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, height);
        let zpass_hash: [u8; 64] = hash_zpass(hashed_worker, zpass_secret);

        assert(worker_exists(hashed_worker));
        assert(worker_zpass_hash.get_or_use(hashed_worker, [0u8; 64]) == zpass_hash);

        let employer_ans: [u8; 32] = get_employer_ans(self.caller);
        let worker_type_flag: u8 = get_worker_type(hashed_worker);

        if worker_type_flag == PAYROLL_FUNCTION_PNCW {
            pncw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else if worker_type_flag == PAYROLL_FUNCTION_PNIW {
            pniw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.aleo::execute_weekly_payroll(hashed_worker, hashed_subdao, amount, zpass_hash);
    }

    async transition finalize_payroll(worker_name: bytes, subdao_name: bytes, amount: u64) -> bool {
        let height: u64 = block.height;
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, height);
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, height);

        assert(worker_exists(hashed_worker));

        return process_tax_compliance.aleo::record_payroll_finalization(hashed_worker, hashed_subdao, amount);
    }
}
