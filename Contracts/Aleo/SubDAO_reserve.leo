import credits.aleo;
import payroll_pool.aleo;

program subDAO_reserve.aleo {
    // Mappings
    mapping reserve_balance: address => u64; // Per SubDAO
    mapping tax_obligations: address => u64; // Per SubDAO

    // Constants
    const TAX_RATE: u64 = 10u64; // 10% tax, adjustable

    // Transition: Employer deposits into a SubDAO reserve
    transition deposit(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        let current_balance: u64 = reserve_balance[subDAO];
        reserve_balance[subDAO] = current_balance + amount;
        return true;
    }

    // Transition: Deduct taxes and fund payroll pool
    transition process_funds(subDAO: address) -> bool {
        let current_balance: u64 = reserve_balance[subDAO];
        assert(current_balance > 0u64);

        let tax_amount: u64 = current_balance * TAX_RATE / 100u64;
        let net_amount: u64 = current_balance - tax_amount;

        reserve_balance[subDAO] = 0u64; // Clear reserve
        tax_obligations[subDAO] = tax_obligations[subDAO] + tax_amount;

        payroll_pool.aleo::deposit(subDAO, net_amount);
        return true;
    }

    // Function: Get reserve balance
    function get_reserve_balance(subDAO: address) -> u64 {
        return reserve_balance[subDAO];
    }
}
