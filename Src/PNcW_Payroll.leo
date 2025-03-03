import credits.aleo;
import employer_agreement.aleo;
import subDAO_reserve.aleo;
import main.leo;

program pncw_payroll.aleo {
    mapping employer_funding: [u8; 32] => u64; // Uses employer ANS instead of address
    mapping worker_balances: [u8; 32] => u64; // Uses worker ANS instead of address

    // Transition: Fund payroll for an employer
    transition fund_payroll(employer_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);
        assert(employer_agreement.aleo::employer_registry.contains(employer_ans));
        assert(employer_agreement.aleo::employer_tax_compliance[employer_ans]);

        let current_funding: u64 = employer_funding[employer_ans];
        let new_funding: u64 = current_funding.checked_add(amount);
        employer_funding[employer_ans] = new_funding;

        credits.aleo::transfer_public(subDAO_reserve.aleo::SUBDAO_RESERVE, amount);
        subDAO_reserve.aleo::deposit(subDAO_reserve.aleo::SUBDAO_RESERVE, amount);
        return true;
    }

    // Transition: Execute payroll for a worker
    transition execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u64) -> bool {
        assert(main.leo::worker_type[worker_ans] == 0u8); // PNcW workers only
        assert(employer_funding[employer_ans] >= amount);

        let updated_funding: u64 = employer_funding[employer_ans].checked_sub(amount);
        employer_funding[employer_ans] = updated_funding;

        let worker_balance: u64 = worker_balances[worker_ans].checked_add(amount);
        worker_balances[worker_ans] = worker_balance;

        credits.aleo::transfer_public(main.leo::lookup_worker_by_ans(worker_ans), amount);
        return true;
    }

    // Function: Verify worker's payroll balance
    function verify_worker_balance(worker_ans: [u8; 32]) -> u64 {
        return worker_balances[worker_ans];
    }
}
