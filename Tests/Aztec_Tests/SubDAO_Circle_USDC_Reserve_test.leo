// SubDAO Circle USDC Reserve Test
mod subdao_circle_usdc_reserve_test {

    import subdao_circle_usdc_reserve;

    // ✅ Test: Employer Deposits into SubDAO Circle USDC Reserve
    fn test_deposit_to_subdao_circle() {
        let employer = Address::from("0x123...");
        let amount = 5000;

        // Employer deposits payroll funds
        subdao_circle_usdc_reserve::deposit(employer, amount);

        // Verify employer balance in reserve
        let stored_balance = subdao_circle_usdc_reserve::get_balance(employer);
        assert(stored_balance == amount, "Deposit amount mismatch");
    }

    // ✅ Test: Payroll Execution Withdraws from SubDAO Circle USDC Reserve
    fn test_payroll_withdrawal() {
        let employer = Address::from("0x123...");
        let worker = Address::from("0x456...");
        let amount = 2000;

        // Employer deposits payroll funds
        subdao_circle_usdc_reserve::deposit(employer, amount);

        // Execute payroll (worker withdrawal)
        subdao_circle_usdc_reserve::transfer(worker, amount);

        // Verify new employer balance
        let remaining_balance = subdao_circle_usdc_reserve::get_balance(employer);
        assert(remaining_balance == 3000, "Incorrect remaining balance after withdrawal");

        // Verify worker received funds
        let worker_balance = subdao_circle_usdc_reserve::get_balance(worker);
        assert(worker_balance == amount, "Worker did not receive payroll correctly");
    }
}
