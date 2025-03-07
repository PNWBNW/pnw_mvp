import credits.leo;
import employer_agreement.leo;
import subdao_reserve.leo;
import main.leo;

program pniw_payroll.leo {
    mapping employer_funding: [u8; 32] => u64;
    mapping worker_balances: [u8; 32] => u64;

    async transition fund_payroll(employer_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);
        assert(employer_agreement.leo::employer_registry.contains(employer_ans));
        assert(employer_agreement.leo::employer_tax_compliance[employer_ans]);

        let current_funding: u64 = employer_funding[employer_ans];
        let new_funding: u64 = current_funding.checked_add(amount);
        Mapping::set(employer_funding, employer_ans, new_funding);

        credits.leo::transfer_public(subDAO_reserve.leo::SUBDAO_RESERVE, amount);
        subDAO_reserve.leo::deposit(subDAO_reserve.leo::SUBDAO_RESERVE, amount);
        
        return (true, fund_payroll);
    }

    async transition execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u64) 
        -> (bool, async transition) {
        assert(main.leo::worker_type[worker_ans] == 1u8);
        assert(employer_funding[employer_ans] >= amount);

        let updated_funding: u64 = employer_funding[employer_ans].checked_sub(amount);
        Mapping::set(employer_funding, employer_ans, updated_funding);

        let worker_balance: u64 = worker_balances[worker_ans].checked_add(amount);
        Mapping::set(worker_balances, worker_ans, worker_balance);

        credits.leo::transfer_public(main.leo::lookup_worker_by_ans(worker_ans), amount);
        
        return (true, execute_payroll);
    }

    function verify_worker_balance(worker_ans: [u8; 32]) -> u64 {
        return worker_balances[worker_ans];
    }
}
