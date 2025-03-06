import credits.aleo;
import weekly_payroll_pool.aleo;
import process_tax_compliance.aleo;

program subDAO_reserve.aleo {
    mapping reserve_balance: [u8; 32] => u64;
    mapping tax_obligations: [u8; 32] => u64;

    const TAX_RATE: u64 = 10u64;

    async transition deposit(subdao_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance[subdao_ans];
        let new_balance: u64 = current_balance.checked_add(amount);
        Mapping::set(reserve_balance, subdao_ans, new_balance);

        return (true, deposit);
    }

    async transition process_taxes(subdao_ans: [u8; 32]) -> (bool, async transition) {
        let current_balance: u64 = reserve_balance[subdao_ans];
        assert(current_balance > 0u64);

        let tax_amount: u64 = current_balance.checked_mul(TAX_RATE).checked_div(100u64);
        let net_amount: u64 = current_balance.checked_sub(tax_amount);

        Mapping::set(reserve_balance, subdao_ans, net_amount);

        let new_tax_obligation: u64 = tax_obligations[subdao_ans].checked_add(tax_amount);
        Mapping::set(tax_obligations, subdao_ans, new_tax_obligation);

        credits.aleo::transfer_public(process_tax_compliance.aleo::TAX_SINK, tax_amount);
        return (true, process_taxes);
    }

    async transition fund_weekly_payroll(subdao_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance[subdao_ans];
        assert(current_balance >= amount);

        let new_balance: u64 = current_balance.checked_sub(amount);
        Mapping::set(reserve_balance, subdao_ans, new_balance);

        weekly_payroll_pool.aleo::fund_weekly_pool(subdao_ans, amount);
        return (true, fund_weekly_payroll);
    }

    function get_reserve_balance(subdao_ans: [u8; 32]) -> u64 {
        return reserve_balance[subdao_ans];
    }
}
