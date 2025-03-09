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
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];
    mapping subdao_ans_registry: [u8; 32] => [u8; 32];
    mapping subdao_reverse_lookup: [u8; 32] => [u8; 32];

    const SUBDAO_RESERVE_ANS: [u8; 32] = hash_poseidon(*b"subdao_reserve.pnw.ans");
    const OVERSIGHT_DAO_ANS: [u8; 32] = hash_poseidon(*b"oversightdao.pnw.ans");

    struct Worker {
        worker_ans: [u8; 32],
        category: u8,
        last_updated: u64
    }

    function hash_worker_ans(worker_ans: [u8; 32]) -> [u8; 32] {
        return hash_poseidon(worker_ans);
    }

    function hash_ans_name(ans_name: [u8; 32]) -> [u8; 32] {
        return hash_poseidon(ans_name);
    }

    function worker_exists(worker_ans: [u8; 32]) -> bool {
        return worker_category.contains(hash_worker_ans(worker_ans));
    }

    function get_worker_type(worker_ans: [u8; 32]) -> u8 {
        return Mapping::get_or_use(worker_type, hash_worker_ans(worker_ans), 0u8);
    }

    function get_employer_ans(caller: [u8; 32]) -> [u8; 32] {
        return Mapping::get_or_use(ans_reverse_lookup, caller, [0u8; 32]);
    }

    async transition register_worker(worker_ans: [u8; 32], category: u8, worker_type_flag: u8, zpass_hash: [u8; 64]) 
        -> bool {
        assert(category < 4u8);
        assert(worker_type_flag == 0u8 || worker_type_flag == 1u8);

        let hashed_worker = hash_worker_ans(worker_ans);

        Mapping::set(worker_category, hashed_worker, category);
        Mapping::set(worker_type, hashed_worker, worker_type_flag);
        Mapping::set(worker_zpass_hash, hashed_worker, zpass_hash);

        return true;
    }

    async transition pay_worker(worker_ans: [u8; 32], subdao_ans: [u8; 32], amount: u64, zpass_hash: [u8; 64]) -> bool {
        assert(amount > 0u64);
        assert(worker_exists(worker_ans));

        let worker_type_flag: u8 = get_worker_type(worker_ans);
        let employer_ans: [u8; 32] = get_employer_ans(self.caller);
        let hashed_worker = hash_worker_ans(worker_ans);
        let hashed_subdao = hash_worker_ans(subdao_ans);

        if worker_type_flag == 0u8 {
            pncw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else if worker_type_flag == 1u8 {
            pniw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.aleo::execute_weekly_payroll(hashed_worker, hashed_subdao, amount, zpass_hash);
    }

    async transition fund_weekly_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);

        let hashed_subdao = hash_worker_ans(subdao_ans);

        subdao_reserve.aleo::fund_weekly_payroll(hashed_subdao, amount);
        return weekly_payroll_pool.aleo::fund_weekly_pool(hashed_subdao, amount);
    }

    async transition process_taxes(subdao_ans: [u8; 32]) -> bool {
        let hashed_subdao = hash_worker_ans(subdao_ans);
        return subdao_reserve.aleo::process_taxes(hashed_subdao);
    }

    function lookup_subdao_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        let ans_hash: [u8; 32] = hash_ans_name(ans_name);
        assert(subdao_reverse_lookup.contains(ans_hash));
        return subdao_reverse_lookup[ans_hash];
    }

    function lookup_worker_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        let ans_hash: [u8; 32] = hash_ans_name(ans_name);
        assert(ans_reverse_lookup.contains(ans_hash));
        return ans_reverse_lookup[ans_hash];
    }
}
