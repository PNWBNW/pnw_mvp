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
        let new_balance: u64 = current_balance.checked_add(amount);
        reserve_balance[subDAO] = new_balance;
        
        return true;
    }

    // Transition: Process taxes for the SubDAO
    transition process_taxes(subDAO: address) -> bool {
        let current_balance: u64 = reserve_balance[subDAO];
        assert(current_balance > 0u64);

        let tax_amount: u64 = current_balance.checked_mul(TAX_RATE).checked_div(100u64);
        assert(tax_amount > 0u64); // Prevents zero-credit transfers

        let net_amount: u64 = current_balance.checked_sub(tax_amount);
        reserve_balance[subDAO] = net_amount;
        
        let new_tax_obligation: u64 = tax_obligations[subDAO].checked_add(tax_amount);
        tax_obligations[subDAO] = new_tax_obligation;

        credits.aleo::transfer_public(process_tax_compliance.aleo::TAX_SINK, tax_amount);
        return true;
    }

    // Transition: Fund weekly payroll from SubDAO reserve
    transition fund_weekly_payroll(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        
        let current_balance: u64 = reserve_balance[subDAO];
        let new_balance: u64 = current_balance.checked_sub(amount);
        reserve_balance[subDAO] = new_balance;

        weekly_payroll_pool.aleo::fund_weekly_pool(subDAO, amount);
        return true;
    }

    // Function: Get SubDAO reserve balance
    function get_reserve_balance(subDAO: address) -> u64 {
        return reserve_balance[subDAO];
    }
}
