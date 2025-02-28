import credits.aleo;
import employer_agreement.aleo;
import subDAO_reserve.aleo;
import main.leo;

program pniw_payroll.aleo {
    mapping employer_funding: address => u64;
    mapping worker_balances: address => u64;

    transition fund_payroll(employer: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(employer_agreement.aleo::employer_registry.contains(employer));
        assert(employer_agreement.aleo::employer_tax_compliance[employer]);

        let current_funding: u64 = employer_funding[employer];
        employer_funding[employer] = current_funding + amount;

        credits.aleo::transfer_public(subDAO_reserve.aleo::SUBDAO_RESERVE, amount);
        subDAO_reserve.aleo::deposit(subDAO_reserve.aleo::SUBDAO_RESERVE, amount);
        return true;
    }

    transition execute_payroll(worker: address, employer: address, amount: u64) -> bool {
        assert(main.leo::worker_type[worker] == 1u8); // PNiW only
        assert(employer_funding[employer] >= amount);

        employer_funding[employer] = employer_funding[employer] - amount;
        worker_balances[worker] = worker_balances[worker] + amount;

        credits.aleo::transfer_public(worker, amount);
        return true;
    }

    function verify_worker_balance(worker: address) -> u64 {
        return worker_balances[worker];
    }
}
