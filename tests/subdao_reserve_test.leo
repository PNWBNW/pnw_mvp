import subdao_reserve.leo;
import credits.leo;

program subdao_reserve_test.leo {
    transition test_deposit() -> bool {
        let subdao_ans: [u8; 32] = *b"wa001_subdao.pnw.ans";
        let amount: u64 = 1000u64;

        let (result, _) = subdao_reserve.leo::deposit(subdao_ans, amount);
        assert(result);
        
        let balance: u64 = subdao_reserve.leo::get_reserve_balance(subdao_ans);
        assert(balance == amount);
        return true;
    }

    transition test_process_taxes() -> bool {
        let subdao_ans: [u8; 32] = *b"wa001_subdao.pnw.ans";
        let amount: u64 = 1000u64;

        let (_, _) = subdao_reserve.leo::deposit(subdao_ans, amount);
        let (result, _) = subdao_reserve.leo::process_taxes(subdao_ans);
        assert(result);
        
        let balance: u64 = subdao_reserve.leo::get_reserve_balance(subdao_ans);
        assert(balance == 900u64); // 10% tax = 100u64
        return true;
    }

    transition test_fund_weekly_payroll() -> bool {
        let subdao_ans: [u8; 32] = *b"wa001_subdao.pnw.ans";
        let amount: u64 = 700u64;

        let (_, _) = subdao_reserve.leo::deposit(subdao_ans, 1000u64);
        let (result, _) = subdao_reserve.leo::fund_weekly_payroll(subdao_ans, amount);
        assert(result);
        
        let balance: u64 = subdao_reserve.leo::get_reserve_balance(subdao_ans);
        assert(balance == 200u64);
        return true;
    }
}
