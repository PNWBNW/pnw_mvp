import main.leo;
import credits.aleo;

program main_test.aleo {
    transition test_register_worker() -> bool {
        let worker_ans: [u8; 32] = *b"johndoe.pniw.ans                  ";
        let category: u8 = 0u8;
        let worker_type: u8 = 0u8; 

        let result: main.leo::Worker = main.leo::register_worker(worker_ans, category, worker_type, *b"ZPassHashPlaceholder               ");
        assert(result.worker_ans == worker_ans);
        assert(result.category == category);
        return true;
    }

    transition test_pay_worker(subdao_ans: [u8; 32], employer_ans: [u8; 32]) -> bool {
        let worker_ans: [u8; 32] = *b"johndoe.pniw.ans                  ";
        let amount: u64 = 100u64;

        main.leo::register_worker(worker_ans, 0u8, 0u8, *b"ZPassHashPlaceholder               ");
        main.leo::set_worker_zpass(worker_ans, *b"ZPassHashPlaceholder               ");

        credits.aleo::transfer_public(subdao_ans, 1000u64);
        subDAO_reserve.aleo::deposit(subdao_ans, 1000u64);
        main.leo::fund_weekly_pool(subdao_ans, 700u64);

        let result: bool = main.leo::pay_worker(worker_ans, subdao_ans, amount, *b"ZPassHashPlaceholder               ");
        assert(result);
        return true;
    }
}
