import credits.leo;
import employer_agreement.leo;
import subdao_reserve.leo;
import main.leo;

program pniw_payroll.leo {
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

    async transition execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u64) 
        -> (bool, async transition) {
        assert(Mapping::get_or_use(main.leo::worker_type, worker_ans, 0u8) == 1u8);
        assert(Mapping::get_or_use(employer_funding, employer_ans, 0u64) >= amount);

        let current_funding: u64 = Mapping::get_or_use(employer_funding, employer_ans, 0u64);
        let updated_funding: u64 = current_funding.checked_sub(amount);
        Mapping::set(employer_funding, employer_ans, updated_funding);

        let worker_balance: u64 = Mapping::get_or_use(worker_balances, worker_ans, 0u64).checked_add(amount);
        Mapping::set(worker_balances, worker_ans, worker_balance);

        credits.leo::transfer_public(main.leo::lookup_worker_by_ans(worker_ans), amount);
        
        return (true, execute_payroll);
    }

    function verify_worker_balance(worker_ans: [u8; 32]) -> u64 {
        return Mapping::get_or_use(worker_balances, worker_ans, 0u64);
    }
}
