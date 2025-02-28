import credits.aleo;
import weekly_payroll_pool.aleo;
import process_tax_compliance.aleo;

program subDAO_reserve.aleo {
    // Mappings
    mapping reserve_balance: address => u64;
    mapping tax_obligations: address => u64;

    // Constants
    const TAX_RATE: u64 = 10u64;

    // Transition: Deposit funds into SubDAO reserve
    transition deposit(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        let current_balance: u64 = reserve_balance[subDAO];
        reserve_balance[subDAO] = current_balance + amount;
        return true;
    }

    // Transition: Process taxes for the SubDAO
    transition process_taxes(subDAO: address) -> bool {
        let current_balance: u64 = reserve_balance[subDAO];
        assert(current_balance > 0u64);

        let tax_amount: u64 = current_balance * TAX_RATE / 100u64;
        let net_amount: u64 = current_balance - tax_amount;

        reserve_balance[subDAO] = net_amount;
        tax_obligations[subDAO] = tax_obligations[subDAO] + tax_amount;

        credits.aleo::transfer_public(process_tax_compliance.aleo::TAX_SINK, tax_amount);
        return true;
    }

    // Transition: Fund weekly payroll from SubDAO reserve
    transition fund_weekly_payroll(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        let current_balance: u64 = reserve_balance[subDAO];
        assert(current_balance >= amount);

        reserve_balance[subDAO] = current_balance - amount;
        weekly_payroll_pool.aleo::fund_weekly_pool(subDAO, amount);
        return true;
    }

    // Function: Get SubDAO reserve balance
    function get_reserve_balance(subDAO: address) -> u64 {
        return reserve_balance[subDAO];
    }
}
