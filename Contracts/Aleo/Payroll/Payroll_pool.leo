import credits.aleo;

program payroll_pool.aleo {
    mapping payroll_balance: address => u64; // Per SubDAO
    mapping employer_obligations: address => u64;

    const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
    const OVERSIGHT_ALLOCATION: u64 = 17u64;

    transition deposit(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        let current_balance: u64 = payroll_balance[subDAO];
        payroll_balance[subDAO] = current_balance + amount;
        return true;
    }

    transition withdraw(subDAO: address, amount: u64) -> bool {
        let current_balance: u64 = payroll_balance[subDAO];
        assert(current_balance >= amount);
        payroll_balance[subDAO] = current_balance - amount;
        return true;
    }

    transition allocate_to_oversight(subDAO: address) -> bool {
        let current_balance: u64 = payroll_balance[subDAO];
        let oversight_amount: u64 = current_balance * OVERSIGHT_ALLOCATION / 100u64;
        assert(current_balance >= oversight_amount);
        payroll_balance[subDAO] = current_balance - oversight_amount;
        credits.aleo::transfer_public(OVERSIGHT_DAO, oversight_amount);
        return true;
    }

    transition set_employer_obligation(employer: address, obligation: u64) -> bool {
        employer_obligations[employer] = obligation;
        return true;
    }

    function get_payroll_balance(subDAO: address) -> u64 {
        return payroll_balance[subDAO];
    }
}
