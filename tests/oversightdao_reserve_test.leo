import oversightDAO_reserve.leo;
import credits.leo;

program oversightdao_reserve_test.leo {
    transition test_deposit() -> bool {
        let oversightdao_ans: [u8; 32] = *b"oversightdao.pnw.ans";
        let amount: u64 = 170u64;

        let (result, _) = oversightdao_reserve.leo::deposit(oversightdao_ans, amount);
        assert(result);
        
        let balance: u64 = oversightdao_reserve.leo::get_reserve_balance();
        assert(balance >= amount);
        return true;
    }

    transition test_withdraw(subdao_ans: [u8; 32]) -> bool {
        let oversightdao_ans: [u8; 32] = *b"oversightdao.pnw.ans";
        let amount: u64 = 100u64;

        let (_, _) = oversightdao_reserve.leo::deposit(oversightdao_ans, 200u64);
        let (result, _) = oversightDAO_reserve.leo::withdraw(subdao_ans, amount);
        assert(result);
        
        let balance: u64 = oversightdao_reserve.leo::get_reserve_balance();
        assert(balance == 100u64);
        return true;
    }
}
