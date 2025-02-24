program pniw_payroll_test.leo;

import pniw_payroll;
import payroll_pool;
import main;

// Constants
const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;

// Test: Employer Funds PNiW Payroll through Payroll Pool
function test_employer_funds_pniw_payroll() {
    let employer = caller();
    let amount = 5000u64;
    
    // Employer funds payroll pool first
    payroll_pool::deposit_aleo_native(employer, amount);
    
    // Employer allocates payroll from payroll pool
    pniw_payroll::fund_payroll(employer, amount);
    
    // Verify employer balance in payroll reserve
    let stored_balance = payroll_pool::get_payroll_balance();
    assert(stored_balance >= amount, "Payroll funding mismatch in payroll pool");
}

// Test: Execute Payroll for PNiW Worker from Payroll Pool
function test_execute_pniw_payroll() {
    let employer = caller();
    let worker = caller();
    let amount = 2000u64;
    
    // Employer funds payroll pool first
    payroll_pool::deposit_aleo_native(employer, amount);
    
    // Employer allocates payroll from payroll pool
    pniw_payroll::fund_payroll(employer, amount);
    
    // Execute payroll
    pniw_payroll::execute_payroll(worker, employer, amount);
    
    // Verify worker received payroll
    let worker_balance = pniw_payroll::verify_worker_balance(worker);
    assert(worker_balance == amount, "Worker did not receive payroll correctly");
    
    // Verify payroll pool has deducted the amount
    let remaining_balance = payroll_pool::get_payroll_balance();
    assert(remaining_balance >= 3000u64, "Payroll pool balance incorrect after withdrawal");
}
