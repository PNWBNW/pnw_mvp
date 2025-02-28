import subDAO_reserve.leo;
import credits.aleo;

program subDAO_reserve_test.aleo {
    transition test_deposit(subDAO: address) -> bool {
        let amount: u64 = 830u64;
        let result: bool = subDAO_reserve.leo::deposit(subDAO, amount);
        assert(result);
        
        let balance: u64 = subDAO_reserve.leo::get_reserve_balance(subDAO);
        assert(balance == amount);
        return true;
    }

    transition test_process_taxes(subDAO: address) -> bool {
        let amount: u64 = 1000u64;
        subDAO_reserve.leo::deposit(subDAO, amount);
        
        let result: bool = subDAO_reserve.leo::process_taxes(subDAO);
        assert(result);
        
        let balance: u64 = subDAO_reserve.leo::get_reserve_balance(subDAO);
        assert(balance == 900u64); // 10% tax = 100u64
        return true;
    }

    transition test_fund_weekly_payroll(subDAO: address) -> bool {
        let amount: u64 = 700u64;
        subDAO_reserve.leo::deposit(subDAO, 1000u64);
        
        let result: bool = subDAO_reserve.leo::fund_weekly_payroll(subDAO, amount);
        assert(result);
        
        let balance: u64 = subDAO_reserve.leo::get_reserve_balance(subDAO);
        assert(balance == 300u64);
        return true;
    }
}
