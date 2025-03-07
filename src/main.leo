import credits.leo;
import employer_agreement.leo;
import process_tax_compliance.leo;
import weekly_payroll_pool.leo;
import pncw_payroll.leo;
import pniw_payroll.leo;
import subDAO_reserve.leo;

program main.leo {
    mapping worker_category: [u8; 32] => u8;
    mapping worker_zpass_hash: [u8; 32] => [u8; 64];
    mapping worker_type: [u8; 32] => u8;
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];
    mapping subDAO_ans_registry: [u8; 32] => [u8; 32];
    mapping subDAO_reverse_lookup: [u8; 32] => [u8; 32];

    const SUBDAO_RESERVE_ANS: [u8; 32] = *b"subdao_reserve.pnw.ans";
    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";

    struct Worker {
        worker_ans: [u8; 32],
        category: u8,
        last_updated: u64
    }

    async transition register_worker(worker_ans: [u8; 32], category: u8, worker_type_flag: u8, zpass_hash: [u8; 64]) 
        -> (Worker, async transition) {
        assert(category < 4u8);
        assert(worker_type_flag == 0u8 || worker_type_flag == 1u8);

        Mapping::set(worker_category, worker_ans, category);
        Mapping::set(worker_type, worker_ans, worker_type_flag);
        Mapping::set(worker_zpass_hash, worker_ans, zpass_hash);

        let worker_record: Worker = Worker {
            worker_ans,
            category,
            last_updated: block.height
        };

        return (worker_record, register_worker);
    }

    async transition set_worker_zpass(worker_ans: [u8; 32], zpass_hash: [u8; 64]) -> (bool, async transition) {
        assert(worker_category.contains(worker_ans));

        Mapping::set(worker_zpass_hash, worker_ans, zpass_hash);
        return (true, set_worker_zpass);
    }

    async transition register_worker_ans(worker_ans: [u8; 32], ans_name: [u8; 32]) -> (bool, async transition) {
        assert(worker_category.contains(worker_ans));
        assert(!ans_reverse_lookup.contains(ans_name));

        Mapping::set(ans_registry, worker_ans, ans_name);
        Mapping::set(ans_reverse_lookup, ans_name, worker_ans);

        return (true, register_worker_ans);
    }

    async transition register_subdao_ans(subdao_ans: [u8; 32], ans_name: [u8; 32]) -> (bool, async transition) {
        assert(!subdao_ans_registry.contains(subdao_ans));
        assert(!subdao_reverse_lookup.contains(ans_name));

        Mapping::set(subdao_ans_registry, subdao_ans, ans_name);
        Mapping::set(subdao_reverse_lookup, ans_name, subdao_ans);

        return (true, register_subDAO_ans);
    }

    transition pay_worker(worker_ans: [u8; 32], subdao_ans: [u8; 32], amount: u64, zpass_hash: [u8; 64]) -> bool {
        assert(amount > 0u64);
        assert(worker_category.contains(worker_ans));
        assert(worker_zpass_hash[worker_ans] == zpass_hash);

        let employer_ans: [u8; 32] = ans_reverse_lookup[self.caller];
        let worker_type_flag: u8 = worker_type[worker_ans];

        if worker_type_flag == 0u8 {
            pncw_payroll.leo::execute_payroll(worker_ans, employer_ans, amount);
        } else if worker_type_flag == 1u8 {
            pniw_payroll.leo::execute_payroll(worker_ans, employer_ans, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.leo::execute_weekly_payroll(worker_ans, subdao_ans, amount, zpass_hash);
    }

    transition fund_weekly_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);
        subDAO_reserve.leo::fund_weekly_payroll(subdao_ans, amount);
        return weekly_payroll_pool.leo::fund_weekly_pool(subdao_ans, amount);
    }

    transition process_taxes(subdao_ans: [u8; 32]) -> bool {
        return subDAO_reserve.leo::process_taxes(subdao_ans);
    }

    function lookup_subdao_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(subdao_reverse_lookup.contains(ans_name));
        return subdao_reverse_lookup[ans_name];
    }

    function lookup_worker_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }
}
