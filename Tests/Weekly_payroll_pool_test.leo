import weekly_payroll_pool.leo;
import credits.aleo;
import main.leo;

program weekly_payroll_pool_test.aleo {
    transition test_fund_weekly_pool(subDAO: address) -> bool {
        let amount: u64 = 700u64;
        let result: bool = weekly_payroll_pool.leo::fund_weekly_pool(subDAO, amount);
        assert(result);
        
        let balance: u64 = weekly_payroll_pool.leo::get_weekly_balance(subDAO);
        assert(balance == amount);
        return true;
    }

    transition test_execute_weekly_payroll(subDAO: address, employer: address) -> bool {
        let worker: address = aleo1worker1234567890example;
        let amount: u64 = 100u64;

        // Setup worker in main.leo
        main.leo::register_worker(worker, *b"General             ", 0u8);
        main.leo::set_worker_zpass(worker, true);

        weekly_payroll_pool.leo::fund_weekly_pool(subDAO, 700u64);
        let result: bool = weekly_payroll_pool.leo::execute_weekly_payroll(worker, subDAO, amount);
        assert(result);
        
        let balance: u64 = weekly_payroll_pool.leo::get_weekly_balance(subDAO);
        assert(balance == 600u64);
        return true;
    }
}
