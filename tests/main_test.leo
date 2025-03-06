import main.leo;
import credits.aleo;
import subDAO_reserve.aleo;

program main_test.aleo {
    transition test_register_worker() -> bool {
        let worker_ans: [u8; 32] = *b"johndoe.pniw.ans";
        let category: u8 = 0u8;
        let worker_type: u8 = 0u8;
        let zpass_hash: [u8; 64] = *b"ZPassHashPlaceholder";

        let (result, _) = main.leo::register_worker(worker_ans, category, worker_type, zpass_hash);
        assert(result.worker_ans == worker_ans);
        assert(result.category == category);
        return true;
    }

    transition test_pay_worker(subdao_ans: [u8; 32], employer_ans: [u8; 32]) -> bool {
        let worker_ans: [u8; 32] = *b"johndoe.pniw.ans";
        let amount: u64 = 100u64;
        let zpass_hash: [u8; 64] = *b"ZPassHashPlaceholder";

        let (_, _) = main.leo::register_worker(worker_ans, 0u8, 0u8, zpass_hash);
        let (_, _) = main.leo::set_worker_zpass(worker_ans, zpass_hash);

        credits.aleo::transfer_public(subdao_ans, 1000u64);
        let (_, _) = subDAO_reserve.aleo::deposit(subdao_ans, 1000u64);
        let (_, _) = main.leo::fund_weekly_pool(subdao_ans, 700u64);

        let result: bool = main.leo::pay_worker(worker_ans, subdao_ans, amount, zpass_hash);
        assert(result);
        return true;
    }
}
