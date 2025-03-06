import weekly_payroll_pool.leo;
import credits.aleo;
import main.leo;

program weekly_payroll_pool_test.aleo {
    transition test_fund_weekly_pool(subdao_ans: [u8; 32]) -> bool {
        let amount: u64 = 700u64;
        
        let (result, _) = weekly_payroll_pool.leo::fund_weekly_pool(subdao_ans, amount);
        assert(result);
        
        let balance: u64 = weekly_payroll_pool.leo::get_weekly_balance(subdao_ans);
        assert(balance == amount);
        return true;
    }

    transition test_execute_weekly_payroll(subdao_ans: [u8; 32], employer_ans: [u8; 32]) -> bool {
        let worker_ans: [u8; 32] = *b"johndoe.pniw.ans";
        let amount: u64 = 100u64;
        let zpass_hash: [u8; 64] = *b"ZPassHashPlaceholder";

        let (_, _) = main.leo::register_worker(worker_ans, 0u8, 0u8, zpass_hash);
        let (_, _) = main.leo::set_worker_zpass(worker_ans, zpass_hash);
        let (_, _) = weekly_payroll_pool.leo::fund_weekly_pool(subdao_ans, 700u64);
        
        let (result, _) = weekly_payroll_pool.leo::execute_weekly_payroll(worker_ans, subdao_ans, amount, zpass_hash);
        assert(result);
        
        let balance: u64 = weekly_payroll_pool.leo::get_weekly_balance(subdao_ans);
        assert(balance == 600u64);
        return true;
    }
}
