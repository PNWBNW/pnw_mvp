import credits.aleo;
import weekly_payroll_pool.aleo;
import process_tax_compliance.aleo;

program subDAO_reserve.aleo {
    // Mappings
    mapping reserve_balance: [u8; 32] => u64; // Uses SubDAO ANS instead of address
    mapping tax_obligations: [u8; 32] => u64;

    // Constants
    const TAX_RATE: u64 = 10u64;

    // Transition: Deposit funds into SubDAO reserve
    transition deposit(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);
        
        let current_balance: u64 = reserve_balance[subdao_ans];
        let new_balance: u64 = current_balance.checked_add(amount);
        reserve_balance[subdao_ans] = new_balance;

        return true;
    }

    // Transition: Process taxes for the SubDAO
    transition process_taxes(subdao_ans: [u8; 32]) -> bool {
        let current_balance: u64 = reserve_balance[subdao_ans];
        assert(current_balance > 0u64);

        let tax_amount: u64 = current_balance.checked_mul(TAX_RATE).checked_div(100u64);
        let net_amount: u64 = current_balance.checked_sub(tax_amount);

        reserve_balance[subdao_ans] = net_amount;

        let new_tax_obligation: u64 = tax_obligations[subdao_ans].checked_add(tax_amount);
        tax_obligations[subdao_ans] = new_tax_obligation;

        credits.aleo::transfer_public(process_tax_compliance.aleo::TAX_SINK, tax_amount);
        return true;
    }

    // Transition: Fund weekly payroll from SubDAO reserve
    transition fund_weekly_payroll(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance[subdao_ans];
        assert(current_balance >= amount);

        let new_balance: u64 = current_balance.checked_sub(amount);
        reserve_balance[subdao_ans] = new_balance;

        weekly_payroll_pool.aleo::fund_weekly_pool(subdao_ans, amount);
        return true;
    }

    // Function: Get SubDAO reserve balance
    function get_reserve_balance(subdao_ans: [u8; 32]) -> u64 {
        return reserve_balance[subdao_ans];
    }
}
