// PNiW Payroll Test
program pniw_payroll_test.aleo;

import pniw_payroll;

function test_pniw_payroll_execution() {
    let employer = aleo::account::new();
    let worker = aleo::account::new();
    let payroll_amount = 1200u64;

    // Employer funds payroll
    pniw_payroll::fund_payroll(employer, payroll_amount);

    // Execute payroll
    pniw_payroll::execute_payroll(worker, employer, payroll_amount);

    // Verify worker received payroll
    let worker_balance = pniw_payroll::verify_worker_balance(worker);
    assert(worker_balance == payroll_amount, "Worker balance mismatch");
}
