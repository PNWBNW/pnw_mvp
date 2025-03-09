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

    const SUBDAO_RESERVE_ANS: [u8; 32] = hash_poseidon(bytes_to_field(b"subdao:subdao_reserve:0"));
    const OVERSIGHT_DAO_ANS: [u8; 32] = hash_poseidon(bytes_to_field(b"subdao:oversightdao:0"));

    function hash_worker_ans(worker_name: bytes, height: u64) -> [u8; 32] {
        let key: bytes = b"worker:" ++ worker_name ++ b":" ++ height as string as bytes;
        return hash_poseidon(bytes_to_field(key));
    }

    function hash_subdao_ans(subdao_name: bytes, height: u64) -> [u8; 32] {
        let key: bytes = b"subdao:" ++ subdao_name ++ b":" ++ height as string as bytes;
        return hash_poseidon(bytes_to_field(key));
    }

    function hash_zpass(worker_ans: [u8; 32], secret: bytes) -> [u8; 64] {
        let key: bytes = b"zpass:" ++ worker_ans ++ secret;
        let field1: field = bytes_to_field(key);
        let part1: [u8; 32] = hash_poseidon(field1);
        let part2: [u8; 32] = hash_poseidon(field1 + 1field);
        return part1 ++ part2;
    }

    function hash_ans_name(ans_name: bytes, entity_type: bytes) -> [u8; 32] {
        let key: bytes = b"ans:" ++ ans_name ++ b":" ++ entity_type;
        return hash_poseidon(bytes_to_field(key));
    }

    function set_worker(hashed_worker: [u8; 32], category: u8, type_flag: u8, zpass_hash: [u8; 64]) {
        Mapping::set(worker_category, hashed_worker, category);
        Mapping::set(worker_type, hashed_worker, type_flag);
        Mapping::set(worker_zpass_hash, hashed_worker, zpass_hash);
    }

    function set_worker_ans(hashed_worker: [u8; 32], ans_name: [u8; 32]) {
        Mapping::set(ans_registry, hashed_worker, ans_name);
        Mapping::set(ans_reverse_lookup, ans_name, hashed_worker);
    }

    function set_subdao_ans(hashed_subdao: [u8; 32], ans_name: [u8; 32]) {
        Mapping::set(subdao_ans_registry, hashed_subdao, ans_name);
        Mapping::set(subdao_reverse_lookup, ans_name, hashed_subdao);
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

        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, block.height);
        let zpass_hash: [u8; 64] = hash_zpass(hashed_worker, zpass_secret);
        set_worker(hashed_worker, category, worker_type_flag, zpass_hash);
        return true;
    }

    async transition register_worker_ans(worker_name: bytes, ans_domain: bytes) -> bool {
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, block.height);
        let hashed_ans: [u8; 32] = hash_ans_name(ans_domain, b"worker");
        assert(worker_exists(hashed_worker));
        assert(!ans_reverse_lookup.contains(hashed_ans));
        set_worker_ans(hashed_worker, hashed_ans);
        return true;
    }

    async transition register_subdao_ans(subdao_name: bytes, ans_domain: bytes) -> bool {
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, block.height);
        let hashed_ans: [u8; 32] = hash_ans_name(ans_domain, b"subdao");
        assert(!subdao_ans_registry.contains(hashed_subdao));
        assert(!subdao_reverse_lookup.contains(hashed_ans));
        set_subdao_ans(hashed_subdao, hashed_ans);
        return true;
    }

    async transition pay_worker(worker_name: bytes, subdao_name: bytes, amount: u64, zpass_hash: [u8; 64]) -> bool {
        let hashed_worker: [u8; 32] = hash_worker_ans(worker_name, block.height);
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, block.height);
        assert(amount > 0u64);
        assert(worker_exists(hashed_worker));

        let worker_type_flag: u8 = get_worker_type(hashed_worker);
        let employer_ans: [u8; 32] = get_employer_ans(self.caller);

        if worker_type_flag == 0u8 {
            pncw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else if worker_type_flag == 1u8 {
            pniw_payroll.aleo::execute_payroll(hashed_worker, employer_ans, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.aleo::execute_weekly_payroll(hashed_worker, hashed_subdao, amount, zpass_hash);
    }

    async transition fund_weekly_pool(subdao_name: bytes, amount: u64) -> bool {
        assert(amount > 0u64);
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, block.height);
        subdao_reserve.aleo::fund_weekly_payroll(hashed_subdao, amount);
        return weekly_payroll_pool.aleo::fund_weekly_pool(hashed_subdao, amount);
    }

    async transition process_taxes(subdao_name: bytes) -> bool {
        let hashed_subdao: [u8; 32] = hash_subdao_ans(subdao_name, block.height);
        return subdao_reserve.aleo::process_taxes(hashed_subdao);
    }

    function lookup_subdao_by_ans(ans_name: bytes) -> [u8; 32] {
        let hashed_ans: [u8; 32] = hash_ans_name(ans_name, b"subdao");
        assert(subdao_reverse_lookup.contains(hashed_ans));
        return subdao_reverse_lookup[hashed_ans];
    }

    function lookup_worker_by_ans(ans_name: bytes) -> [u8; 32] {
        let hashed_ans: [u8; 32] = hash_ans_name(ans_name, b"worker");
        assert(ans_reverse_lookup.contains(hashed_ans));
        return ans_reverse_lookup[hashed_ans];
    }
}
