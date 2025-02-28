import credits.aleo;
import subDAO_reserve.aleo;
import main.leo;
import pncw_payroll.aleo;
import pniw_payroll.aleo;

program weekly_payroll_pool.aleo {
    // Mapping
    mapping weekly_balance: address => u64;

    // Transition: Fund the weekly payroll pool
    transition fund_weekly_pool(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        let current_balance: u64 = weekly_balance[subDAO];
        weekly_balance[subDAO] = current_balance + amount;
        return true;
    }

    // Transition: Execute weekly payroll for a worker
    transition execute_weekly_payroll(worker: address, subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(main.leo::worker_category.contains(worker));
        assert(main.leo::worker_zpass_verified[worker]);

        let weekly_funds: u64 = weekly_balance[subDAO];
        assert(weekly_funds >= amount);
        weekly_balance[subDAO] = weekly_funds - amount;

        credits.aleo::transfer_public(worker, amount);

        let employer: address = self.caller;
        let worker_type: u8 = main.leo::worker_type[worker];
        if worker_type == 0u8 {
            pncw_payroll.aleo::execute_payroll(worker, employer, amount);
        } else if worker_type == 1u8 {
            pniw_payroll.aleo::execute_payroll(worker, employer, amount);
        } else {
            assert(false);
        }

        return true;
    }

    // Function: Get weekly balance for a SubDAO
    function get_weekly_balance(subDAO: address) -> u64 {
        return weekly_balance[subDAO];
    }
}
