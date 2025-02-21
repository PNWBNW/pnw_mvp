// PNcW Payroll Test
program pncw_payroll_test.aleo;

import pncw_payroll;

function test_pncw_payroll_execution() {
    let employer = aleo::account::new();
    let worker = aleo::account::new();
    let payroll_amount = 1500u64;

    // Employer funds payroll
    pncw_payroll::fund_payroll(employer, payroll_amount);

    // Execute payroll
    pncw_payroll::execute_payroll(worker, employer, payroll_amount);

    // Verify worker received payroll
    let worker_balance = pncw_payroll::verify_worker_balance(worker);
    assert(worker_balance == payroll_amount, "Worker balance mismatch");
}
