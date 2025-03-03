import oversightDAO_reserve.leo;
import credits.aleo;

program oversightDAO_reserve_test.aleo {
    transition test_deposit() -> bool {
        let oversightDAO_ans: [u8; 32] = *b"oversightdao.pnw.ans";
        let amount: u64 = 170u64;

        let result: bool = oversightDAO_reserve.leo::deposit(oversightDAO_ans, amount);
        assert(result);
        
        let balance: u64 = oversightDAO_reserve.leo::get_reserve_balance();
        assert(balance >= amount);
        return true;
    }

    transition test_withdraw(subdao_ans: [u8; 32]) -> bool {
        let oversightDAO_ans: [u8; 32] = *b"oversightdao.pnw.ans";
        let amount: u64 = 100u64;

        oversightDAO_reserve.leo::deposit(oversightDAO_ans, 200u64);
        let result: bool = oversightDAO_reserve.leo::withdraw(subdao_ans, amount);
        assert(result);
        
        let balance: u64 = oversightDAO_reserve.leo::get_reserve_balance();
        assert(balance == 100u64);
        return true;
    }
}
