import main.leo;
import credits.aleo;

program main_test.aleo {
    transition test_register_worker() -> bool {
        let worker: address = aleo1worker1234567890example;
        let category: [u8; 20] = *b"General             ";
        let worker_type: u8 = 0u8; // PNcW
        
        let result: main.leo::Worker = main.leo::register_worker(worker, category, worker_type);
        assert(result.worker_address == worker);
        assert(result.category == category);
        return true;
    }

    transition test_pay_worker(subDAO: address, employer: address) -> bool {
        let worker: address = aleo1worker1234567890example;
        let amount: u64 = 100u64;

        // Setup: Register and verify worker
        main.leo::register_worker(worker, *b"General             ", 0u8);
        main.leo::set_worker_zpass(worker, true);

        // Fund subDAO_reserve and weekly pool
        credits.aleo::transfer_public(subDAO, 1000u64);
        subDAO_reserve.aleo::deposit(subDAO, 1000u64);
        main.leo::fund_weekly_pool(subDAO, 700u64);

        let result: bool = main.leo::pay_worker(worker, subDAO, amount);
        assert(result);
        return true;
    }
}
