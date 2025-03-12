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

    const WORKER_CATEGORY_FT: u8 = 1u8;
    const WORKER_CATEGORY_CONTRACT: u8 = 2u8;
    const PAYROLL_FUNCTION_PNCW: u8 = 10u8;
    const PAYROLL_FUNCTION_PNIW: u8 = 20u8;

    function encode_ans(ans_name: bytes) -> [u8; 32] {
        return hash_arc721(ans_name);
    }

    function encode_zpass(worker_ans: [u8; 32], secret: bytes) -> [u8; 64] {
        let part1: [u8; 32] = hash_arc721(worker_ans ++ secret);
        let part2: [u8; 32] = hash_arc721(worker_ans ++ secret ++ b":part2");
        return part1 ++ part2;
    }

    function worker_exists(hashed_worker: [u8; 32]) -> bool {
        return worker_category.contains(hashed_worker);
    }

    async transition register_worker(worker_name: bytes, category: u8, worker_type_flag: u8, zpass_secret: bytes) -> bool {
        assert(category == WORKER_CATEGORY_FT || category == WORKER_CATEGORY_CONTRACT);
        assert(worker_type_flag == PAYROLL_FUNCTION_PNCW || worker_type_flag == PAYROLL_FUNCTION_PNIW);

        let hashed_worker: [u8; 32] = encode_ans(worker_name);
        let zpass_hash: [u8; 64] = encode_zpass(hashed_worker, zpass_secret);

        worker_category.set(hashed_worker, category);
        worker_type.set(hashed_worker, worker_type_flag);
        worker_zpass_hash.set(hashed_worker, zpass_hash);

        return true;
    }

    async transition register_worker_ans(worker_name: bytes, ans_domain: bytes) -> bool {
        let hashed_worker: [u8; 32] = encode_ans(worker_name);
        let hashed_ans: [u8; 32] = encode_ans(ans_domain);

        assert(worker_exists(hashed_worker));
        assert(!ans_reverse_lookup.contains(hashed_ans));

        ans_registry.set(hashed_worker, hashed_ans);
        ans_reverse_lookup.set(hashed_ans, hashed_worker);

        return true;
    }

    async transition finalize_worker_registration(worker_name: bytes) -> bool {
        let hashed_worker: [u8; 32] = encode_ans(worker_name);
        assert(worker_exists(hashed_worker));
        return true;
    }
}
