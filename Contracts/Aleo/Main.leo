import credits.aleo;
import payroll_pool.aleo;

program main.leo {
    // Mappings (defined at program level, used in transitions)
    mapping worker_category: address => [u8; 20];
    mapping worker_zpass_verified: address => bool;
    mapping ans_registry: address => [u8; 20];
    mapping ans_reverse_lookup: [u8; 20] => address;
    mapping subDAO_ans_registry: address => [u8; 20];
    mapping subDAO_reverse_lookup: [u8; 20] => address;

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

    // Transition: Pay worker
    transition pay_worker(worker: address, subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(worker_category.contains(worker));
        assert(worker_zpass_verified[worker]);

        let pool_balance: u64 = payroll_pool.aleo::get_payroll_balance(subDAO);
        assert(pool_balance >= amount);

        payroll_pool.aleo::withdraw(subDAO, amount);
        credits.aleo::transfer_public(worker, amount);
        return true;
    }

    // Transition: Allocate to OversightDAO
    transition allocate_to_oversight(subDAO: address) -> bool {
        return payroll_pool.aleo::allocate_to_oversight(subDAO);
    }

    // Transition: Assign worker category
    transition set_worker_category(worker: address, category: [u8; 20]) -> Worker {
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

        worker_category[worker] = category;
        let worker_record: Worker = Worker {
            worker_address: worker,
            category: category,
            last_updated: block.height
        };
        return worker_record;
    }

    // Transition: Set ZPass verification (for compliance)
    transition set_worker_zpass(worker: address, verified: bool) -> bool {
        worker_zpass_verified[worker] = verified;
        return verified;
    }

    // Transition: Allocate funds to OversightDAO
    transition allocate_to_oversight(amount: u64) -> bool {
        assert(amount > 0u64);
        
        let current_balance: u64 = payroll_pools::get_payroll_balance();
        let oversight_amount: u64 = current_balance * OVERSIGHT_ALLOCATION / 100u64;
        
        assert(current_balance >= oversight_amount);
        
        payroll_pools::withdraw(SUBDAO_RESERVE, oversight_amount); // Simplified method name
        credits.aleo::transfer_public(OVERSIGHT_DAO, oversight_amount);
        
        return true;
    }

    // Transition: Register worker ANS
    transition register_worker_ans(worker: address, ans_name: [u8; 20]) -> bool {
        assert(!ans_reverse_lookup.contains(ans_name));
        ans_registry[worker] = ans_name;
        ans_reverse_lookup[ans_name] = worker;
        return true;
    }

    // Function: Lookup SubDAO address
    function lookup_subDAO_by_ans(ans_name: [u8; 20]) -> address {
        assert(subDAO_reverse_lookup.contains(ans_name));
        return subDAO_reverse_lookup[ans_name];
    }

    // Transition: Pay worker
    transition pay_worker(worker: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(worker_category.contains(worker));
        assert(worker_zpass_verified[worker]); // Must be verified
        
        let pool_balance: u64 = payroll_pools::get_payroll_balance();
        assert(pool_balance >= amount);
        
        payroll_pools::withdraw(SUBDAO_RESERVE, amount);
        credits.aleo::transfer_public(worker, amount);
        
        return true;
    }
}
