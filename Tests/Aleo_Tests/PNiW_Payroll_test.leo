program pniw_payroll_test.leo;

import pniw_payroll;
import main;

// Test: Employer Funds PNiW Payroll
function test_employer_funds_pniw_payroll() {
    let employer = caller();
    let amount = 5000u64;
    
    // Employer funds payroll
    pniw_payroll::fund_payroll(employer, amount);
    
    // Verify employer balance in payroll reserve
    let stored_balance = pniw_payroll::verify_worker_balance(employer);
    assert(stored_balance == amount, "Payroll funding mismatch");
}

// Test: Execute Payroll for PNiW Worker
function test_execute_pniw_payroll() {
    let employer = caller();
    let worker = caller();
    let amount = 2000u64;
    
    // Employer funds payroll
    pniw_payroll::fund_payroll(employer, amount);
    
    // Execute payroll
    pniw_payroll::execute_payroll(worker, employer, amount);
    
    // Verify worker received payroll
    let worker_balance = pniw_payroll::verify_worker_balance(worker);
    assert(worker_balance == amount, "Worker did not receive payroll correctly");
}
