import credits.aleo;
import payroll_pool.aleo;
import employer_agreement.aleo;
import process_tax_compliance.aleo;

program main.leo {
    // Mappings
    mapping worker_category: address => [u8; 20];
    mapping worker_zpass_verified: address => bool;
    mapping worker_type: address => u8; // 0 = PNcW (Citizen), 1 = PNiW (Immigrant)
    mapping ans_registry: address => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => address;
    mapping subDAO_ans_registry: address => [u8; 32];
    mapping subDAO_reverse_lookup: [u8; 32] => address;

    // Constants
    const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
    const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
    const OVERSIGHT_ALLOCATION: u64 = 17u64; // 17% allocation

    // Structs
    struct Worker {
        worker_address: address,
        category: [u8; 20],
        last_updated: u64
    }

    // Transition: Register worker with category and type
    transition register_worker(worker: address, category: [u8; 20], worker_type_flag: u8) -> Worker {
        let valid_categories: [[u8; 20]; 4] = [
            *b"General             ",
            *b"Skilled             ",
            *b"Agricultural        ",
            *b"Healthcare          "
        ];
        
        let mut is_valid: bool = false;
        for i in 0..4u32 {
            if category == valid_categories[i] {
                is_valid = true;
            }
        }
        assert(is_valid);

        assert(worker_type_flag == 0u8 || worker_type_flag == 1u8); // PNcW or PNiW

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

    // Transition: Pay worker
    transition pay_worker(worker: address, subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(worker_category.contains(worker));
        assert(worker_zpass_verified[worker]);

        let pool_balance: u64 = payroll_pool.aleo::get_payroll_balance(subDAO);
        assert(pool_balance >= amount);

        // Optional: Check employer tax compliance (uncomment if desired)
        // let employer: address = self.caller; // Assume caller is employer
        // assert(process_tax_compliance.aleo::check_compliance(employer));

        payroll_pool.aleo::withdraw(subDAO, amount);
        credits.aleo::transfer_public(worker, amount);
        
        // Process tax compliance based on worker type
        // Uncomment when pncw/pniw payrolls are ready
        // process_tax_compliance.aleo::process_tax_compliance(employer, worker_type[worker]);
        
        return true;
    }

    // Transition: Allocate funds to OversightDAO from a SubDAO pool
    transition allocate_to_oversight(subDAO: address) -> bool {
        return payroll_pool.aleo::allocate_to_oversight(subDAO);
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
