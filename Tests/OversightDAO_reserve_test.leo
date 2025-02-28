import oversightDAO_reserve.leo;
import credits.aleo;

program oversightDAO_reserve_test.aleo {
    transition test_deposit() -> bool {
        let oversightDAO: address = oversightDAO_reserve.leo::OVERSIGHT_DAO;
        let amount: u64 = 170u64;

        // Simulate credits transfer (manual setup in testnet)
        let result: bool = oversightDAO_reserve.leo::deposit(oversightDAO, amount);
        assert(result);
        
        let balance: u64 = oversightDAO_reserve.leo::get_reserve_balance();
        assert(balance >= amount);
        return true;
    }

    transition test_withdraw(subDAO: address) -> bool {
        let oversightDAO: address = oversightDAO_reserve.leo::OVERSIGHT_DAO;
        let amount: u64 = 100u64;

        oversightDAO_reserve.leo::deposit(oversightDAO, 200u64);
        let result: bool = oversightDAO_reserve.leo::withdraw(subDAO, amount);
        assert(result);
        
        let balance: u64 = oversightDAO_reserve.leo::get_reserve_balance();
        assert(balance == 100u64);
        return true;
    }
}
