import credits.aleo;
import employer_agreement.aleo;
import process_tax_compliance.aleo;
import weekly_payroll_pool.aleo;
import pncw_payroll.aleo;
import pniw_payroll.aleo;
import subDAO_reserve.aleo;

program main.leo {
    // Mappings
    mapping worker_category: [u8; 32] => u8; // 0 = General, 1 = Skilled, 2 = Agricultural, 3 = Healthcare
    mapping worker_zpass_hash: [u8; 32] => [u8; 64]; // ZPass ID stored as a hashed value
    mapping worker_type: [u8; 32] => u8; // 0 = PNcW, 1 = PNiW
    mapping ans_registry: [u8; 32] => [u8; 32]; // Worker ANS registry
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32]; // Worker ANS reverse lookup
    mapping subDAO_ans_registry: [u8; 32] => [u8; 32]; // SubDAO ANS registry
    mapping subDAO_reverse_lookup: [u8; 32] => [u8; 32]; // SubDAO ANS reverse lookup

    // Constants
    const SUBDAO_RESERVE_ANS: [u8; 32] = *b"subdao_reserve.pnw.ans";
    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";

    // Structs
    struct Worker {
        worker_ans: [u8; 32],
        category: u8,
        last_updated: u64
    }

    // Transition: Register worker with category and type
    transition register_worker(worker_ans: [u8; 32], category: u8, worker_type_flag: u8, zpass_hash: [u8; 64]) -> Worker {
        assert(category < 4u8); // Valid categories: 0 = General, 1 = Skilled, 2 = Agricultural, 3 = Healthcare
        assert(worker_type_flag == 0u8 || worker_type_flag == 1u8);

        worker_category[worker_ans] = category;
        worker_type[worker_ans] = worker_type_flag;
        worker_zpass_hash[worker_ans] = zpass_hash; // Store worker's hashed ZPass ID
        
        let worker_record: Worker = Worker {
            worker_ans: worker_ans,
            category: category,
            last_updated: block.height
        };
        return worker_record;
    }

    // Transition: Set worker ZPass verification
    transition set_worker_zpass(worker_ans: [u8; 32], zpass_hash: [u8; 64]) -> bool {
        assert(worker_category.contains(worker_ans));
        worker_zpass_hash[worker_ans] = zpass_hash;
        return true;
    }

    // Transition: Register worker ANS
    transition register_worker_ans(worker_ans: [u8; 32], ans_name: [u8; 32]) -> bool {
        assert(worker_category.contains(worker_ans));
        assert(!ans_reverse_lookup.contains(ans_name));

        ans_registry[worker_ans] = ans_name;
        ans_reverse_lookup[ans_name] = worker_ans;
        return true;
    }

    // Transition: Register SubDAO ANS
    transition register_subDAO_ans(subdao_ans: [u8; 32], ans_name: [u8; 32]) -> bool {
        assert(!subDAO_ans_registry.contains(subdao_ans));
        assert(!subDAO_reverse_lookup.contains(ans_name));

        subDAO_ans_registry[subdao_ans] = ans_name;
        subDAO_reverse_lookup[ans_name] = subdao_ans;
        return true;
    }

    // Transition: Pay worker
    transition pay_worker(worker_ans: [u8; 32], subdao_ans: [u8; 32], amount: u64, zpass_hash: [u8; 64]) -> bool {
        assert(amount > 0u64);
        assert(worker_category.contains(worker_ans));
        assert(worker_zpass_hash[worker_ans] == zpass_hash); // Verify ZPass before payroll

        let employer_ans: [u8; 32] = ans_reverse_lookup[self.caller];
        let worker_type_flag: u8 = worker_type[worker_ans];

        if worker_type_flag == 0u8 {
            pncw_payroll.aleo::execute_payroll(worker_ans, employer_ans, amount);
        } else if worker_type_flag == 1u8 {
            pniw_payroll.aleo::execute_payroll(worker_ans, employer_ans, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.aleo::execute_weekly_payroll(worker_ans, subdao_ans, amount, zpass_hash);
    }

    // Transition: Fund weekly payroll pool
    transition fund_weekly_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);
        subDAO_reserve.aleo::fund_weekly_payroll(subdao_ans, amount);
        return weekly_payroll_pool.aleo::fund_weekly_pool(subdao_ans, amount);
    }

    // Transition: Process taxes for a SubDAO
    transition process_taxes(subdao_ans: [u8; 32]) -> bool {
        return subDAO_reserve.aleo::process_taxes(subdao_ans);
    }

    // Function: Lookup SubDAO by ANS
    function lookup_subDAO_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(subDAO_reverse_lookup.contains(ans_name));
        return subDAO_reverse_lookup[ans_name];
    }

    // Function: Lookup worker by ANS
    function lookup_worker_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }
}
