program payroll_pool_test.leo;

import payroll_pool;

// Constants
const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;

//  Test: Employer Deposits into Payroll Pool
function test_deposit_to_payroll_pool() {
    let employer = caller();
    let amount = 5000u64;
    
    // Employer deposits payroll funds
    payroll_pool::deposit_aleo_native(employer, amount);
    
    // Verify payroll pool balance
    let stored_balance = payroll_pool::get_payroll_balance();
    assert(stored_balance == amount, "Deposit amount mismatch");
}

//  Test: Payroll Execution Withdraws from Payroll Pool
function test_payroll_withdrawal() {
    let employer = caller();
    let amount = 2000u64;
    
    // Employer deposits payroll funds
    payroll_pool::deposit_aleo_native(employer, amount);
    
    // Withdraw from payroll pool
    payroll_pool::withdraw_for_payroll(employer, amount);
    
    // Verify updated payroll pool balance
    let remaining_balance = payroll_pool::get_payroll_balance();
    assert(remaining_balance == 3000u64, "Incorrect remaining balance after withdrawal");
}
