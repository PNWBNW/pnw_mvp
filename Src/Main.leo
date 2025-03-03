import credits.aleo;
import employer_agreement.aleo;
import process_tax_compliance.aleo;
import weekly_payroll_pool.aleo;
import pncw_payroll.aleo;
import pniw_payroll.aleo;
import subDAO_reserve.aleo;

program main.leo {
    // Mappings
    mapping worker_category: address => u8; // 0 = General, 1 = Skilled, 2 = Agricultural, 3 = Healthcare
    mapping worker_zpass_verified: address => bool;
    mapping worker_type: address => u8; // 0 = PNcW, 1 = PNiW
    mapping ans_registry: address => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => address;
    mapping subDAO_ans_registry: address => [u8; 32];
    mapping subDAO_reverse_lookup: [u8; 32] => address;

    // Constants
    const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
    const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;

    // Structs
    struct Worker {
        worker_address: address,
        category: u8,
        last_updated: u64
    }

    // Transition: Register worker with category and type
    transition register_worker(worker: address, category: u8, worker_type_flag: u8) -> Worker {
        assert(category < 4u8); // Valid categories: 0 = General, 1 = Skilled, 2 = Agricultural, 3 = Healthcare
        assert(worker_type_flag == 0u8 || worker_type_flag == 1u8);

        worker_category[worker] = category;
        worker_type[worker] = worker_type_flag;
        
        let worker_record: Worker = Worker {
            worker_address: worker,
            category: category,
            last_updated: block.height
        };
        return worker_record;
    }

    // Transition: Set worker ZPass verification
    transition set_worker_zpass(worker: address, verified: bool) -> bool {
        worker_zpass_verified[worker] = verified;
        return verified;
    }

    // Transition: Register worker ANS
    transition register_worker_ans(worker: address, ans_name: [u8; 32]) -> bool {
        assert(worker_category.contains(worker));
        assert(!ans_reverse_lookup.contains(ans_name));

        ans_registry[worker] = ans_name;
        ans_reverse_lookup[ans_name] = worker;
        return true;
    }

    // Transition: Register SubDAO ANS
    transition register_subDAO_ans(subDAO: address, ans_name: [u8; 32]) -> bool {
        assert(!subDAO_ans_registry.contains(subDAO));
        assert(!subDAO_reverse_lookup.contains(ans_name));

        subDAO_ans_registry[subDAO] = ans_name;
        subDAO_reverse_lookup[ans_name] = subDAO;
        return true;
    }

    // Transition: Pay worker
    transition pay_worker(worker: address, subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(worker_category.contains(worker));
        assert(worker_zpass_verified[worker]);

        let employer: address = self.caller;
        let worker_type_flag: u8 = worker_type[worker];

        if worker_type_flag == 0u8 {
            pncw_payroll.aleo::execute_payroll(worker, employer, amount);
        } else if worker_type_flag == 1u8 {
            pniw_payroll.aleo::execute_payroll(worker, employer, amount);
        } else {
            assert(false);
        }

        return weekly_payroll_pool.aleo::execute_weekly_payroll(worker, subDAO, amount);
    }

    // Transition: Fund weekly payroll pool
    transition fund_weekly_pool(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        subDAO_reserve.aleo::fund_weekly_payroll(subDAO, amount);
        return weekly_payroll_pool.aleo::fund_weekly_pool(subDAO, amount);
    }

    // Transition: Process taxes for a SubDAO
    transition process_taxes(subDAO: address) -> bool {
        return subDAO_reserve.aleo::process_taxes(subDAO);
    }

    // Function: Lookup SubDAO address by ANS
    function lookup_subDAO_by_ans(ans_name: [u8; 32]) -> address {
        assert(subDAO_reverse_lookup.contains(ans_name));
        return subDAO_reverse_lookup[ans_name];
    }

    // Function: Lookup worker address by ANS
    function lookup_worker_by_ans(ans_name: [u8; 32]) -> address {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }
}
