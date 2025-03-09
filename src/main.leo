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

    const SUBDAO_RESERVE_ANS: [u8; 32] = hash_blake3(b"subdao:subdao_reserve:0");
    const OVERSIGHT_DAO_ANS: [u8; 32] = hash_blake3(b"subdao:oversightdao:0");

    function hash_worker_ans(worker_name: bytes, height: u64) -> [u8; 32] {
        let key: bytes = b"worker:" ++ worker_name ++ b":" ++ height as string as bytes;
        return hash_blake3(key);
    }

    function hash_zpass(worker_ans: [u8; 32], secret: bytes) -> [u8; 64] {
        let key: bytes = b"zpass:" ++ worker_ans ++ secret;
        let part1: [u8; 32] = hash_blake3(key);
        let part2: [u8; 32] = hash_poseidon(key);
        return part1 ++ part2;
    }

    function hash_subdao_ans(subdao_name: bytes, height: u64) -> [u8; 32] {
        let key: bytes = b"subdao:" ++ subdao_name ++ b":" ++ height as string as bytes;
        return hash_blake3(key);
    }

    function hash_ans_name(entity_type: bytes, ans_name: bytes) -> [u8; 32] {
        let key: bytes = entity_type ++ b":" ++ ans_name;
        return hash_blake3(key);
    }

    function worker_exists(hashed_worker: [u8; 32]) -> bool {
        return worker_category.contains(hashed_worker);
    }

    function get_worker_type(hashed_worker: [u8; 32]) -> u8 {
        return Mapping::get_or_use(worker_type, hashed_worker, 0u8);
    }

    function get_employer_ans(caller: [u8; 32]) -> [u8; 32] {
        return Mapping::get_or_use(ans_reverse_lookup, caller, [0u8; 32]);
    }

    async transition register_worker(worker_name: bytes, category: u8, worker_type_flag: u8, zpass_secret: bytes) -> bool {
        assert(category < 4u8);
        assert(worker_type_flag == 0u8 || worker_type_flag == 1u8);

        let height: u64 = block.height;
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, height);
        let zpass_hash: [u8; 64] = hash_zpass(hashed_worker, zpass_secret);

        Mapping::set(worker_category, hashed_worker, category);
        Mapping::set(worker_type, hashed_worker, worker_type_flag);
        Mapping::set(worker_zpass_hash, hashed_worker, zpass_hash);

        return true;
    }

    async transition register_worker_ans(worker_name: bytes, ans_domain: bytes) -> bool {
        let height: u64 = block.height;
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, height);
        let hashed_ans: [u8; 32] = hash_ans_name(b"worker", ans_domain);

        assert(worker_exists(hashed_worker));
        assert(!ans_reverse_lookup.contains(hashed_ans));

        Mapping::set(ans_registry, hashed_worker, hashed_ans);
        Mapping::set(ans_reverse_lookup, hashed_ans, hashed_worker);

        return true;
    }

    async transition register_subdao_ans(subdao_name: bytes, ans_domain: bytes) -> bool {
        let height: u64 = block.height;
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, height);
        let hashed_ans: [u8; 32] = hash_ans_name(b"subdao", ans_domain);

        assert(!subdao_ans_registry.contains(hashed_subdao));
        assert(!subdao_reverse_lookup.contains(hashed_ans));

        Mapping::set(subdao_ans_registry, hashed_subdao, hashed_ans);
        Mapping::set(subdao_reverse_lookup, hashed_ans, hashed_subdao);

        return true;
    }

    async transition pay_worker(worker_name: bytes, subdao_name: bytes, amount: u64, zpass_secret: bytes) -> bool {
        assert(amount > 0u64);

        let height: u64 = block.height;
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, height);
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, height);

        assert(worker_exists(hashed_worker));
        assert(worker_zpass_hash[contains(hashed_worker)] == hash_zpass(hashed_worker, zpass_secret));

        let employer_ans: [u8; 32] = get_employer_ans(self.caller);
        let worker_type_flag: u8 = get_worker_type(hashed_worker);

        if worker_type_flag == 0u8 {
            pncw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else if worker_type_flag == 1u8 {
            pniw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.aleo::execute_weekly_payroll(hashed_worker, hashed_subdao, amount, zpass_secret);
    }

    async transition fund_weekly_pool(subdao_name: bytes, amount: u64) -> bool {
        assert(amount > 0u64);
        let height: u64 = block.height;
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, height);

        subdao_reserve.aleo::fund_weekly_payroll(hashed_subdao, amount);
        return weekly_payroll_pool.aleo::fund_weekly_pool(hashed_subdao, amount);
    }

    async transition process_taxes(subdao_name: bytes) -> bool {
        let height: u64 = block.height;
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, height);
        return subdao_reserve.aleo::process_taxes(hashed_subdao);
    }
}
