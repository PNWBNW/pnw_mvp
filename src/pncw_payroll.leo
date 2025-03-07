import credits.leo;
import employer_agreement.leo;
import subdao_reserve.leo;
import main.leo;

program pncw_payroll.leo {
    mapping employer_funding: [u8; 32] => u64;
    mapping worker_balances: [u8; 32] => u64;

    async transition fund_payroll(employer_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);
        assert(Mapping::get_or_use(employer_agreement.leo::employer_registry, employer_ans, false));
        assert(Mapping::get_or_use(employer_agreement.leo::employer_tax_compliance, employer_ans, false));

        let current_funding: u64 = Mapping::get_or_use(employer_funding, employer_ans, 0u64);
        let new_funding: u64 = current_funding.checked_add(amount);
        Mapping::set(employer_funding, employer_ans, new_funding);

        credits.leo::transfer_public(subdao_reserve.leo::SUBDAO_RESERVE_ANS, amount);
        subdao_reserve.leo::deposit(subdao_reserve.leo::SUBDAO_RESERVE_ANS, amount);

        return (true, fund_payroll);
    }

    async transition execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);
        assert(Mapping::get_or_use(main.leo::worker_type, worker_ans, 0u8) == 0u8);

        let current_funding: u64 = Mapping::get_or_use(employer_funding, employer_ans, 0u64);
        assert(current_funding >= amount);

        let updated_funding: u64 = current_funding.checked_sub(amount);
        Mapping::set(employer_funding, employer_ans, updated_funding);

        let current_worker_balance: u64 = Mapping::get_or_use(worker_balances, worker_ans, 0u64);
        let new_worker_balance: u64 = current_worker_balance.checked_add(amount);
        Mapping::set(worker_balances, worker_ans, new_worker_balance);

        credits.leo::transfer_public(worker_ans, amount);

        return (true, execute_payroll);
    }
}
