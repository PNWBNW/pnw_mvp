// SubDAO Aleo USDC Reserve Test
program subdao_aleo_usdc_reserve_test.aleo;

import subdao_aleo_usdc_reserve;

// ✅ Test: Employer Deposits into SubDAO Reserve
function test_deposit_to_subdao_reserve() {
    let employer = aleo::account::new();
    let amount = 5000u64;

    // Employer deposits payroll funds
    subdao_aleo_usdc_reserve::deposit(employer, amount);

    // Verify employer balance in reserve
    let stored_balance = subdao_aleo_usdc_reserve::get_balance(employer);
    assert(stored_balance == amount, "Deposit amount mismatch");
}

// ✅ Test: Payroll Execution Withdraws from SubDAO Reserve
function test_payroll_withdrawal() {
    let employer = aleo::account::new();
    let worker = aleo::account::new();
    let amount = 2000u64;

    // Employer deposits payroll funds
    subdao_aleo_usdc_reserve::deposit(employer, amount);

    // Execute payroll (worker withdrawal)
    subdao_aleo_usdc_reserve::transfer(worker, amount);

    // Verify new employer balance
    let remaining_balance = subdao_aleo_usdc_reserve::get_balance(employer);
    assert(remaining_balance == 3000u64, "Incorrect remaining balance after withdrawal");

    // Verify worker received funds
    let worker_balance = subdao_aleo_usdc_reserve::get_balance(worker);
    assert(worker_balance == amount, "Worker did not receive payroll correctly");
}
