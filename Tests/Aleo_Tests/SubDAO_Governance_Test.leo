// SubDAO Governance Test
program subdao_governance_test.aleo;

import subdao_governance;

// ✅ Test: SubDAO Payroll Approval
function test_subdao_approve_payroll() {
    let subdao = aleo::account::new();
    let employer = aleo::account::new();
    let amount = 2000u64;

    // Employer submits payroll request
    subdao_governance::submit_payroll_request(subdao, employer, amount);

    // SubDAO approves payroll request
    let approval_result = subdao_governance::approve_payroll(subdao, employer, amount);
    assert(approval_result == true, "Payroll approval failed");
}

// ✅ Test: SubDAO Worker Dispute Resolution
function test_worker_dispute_resolution() {
    let subdao = aleo::account::new();
    let worker = aleo::account::new();
    let dispute_id = 1u64;
    let resolution_status = "Resolved";

    // Submit a worker dispute
    subdao_governance::submit_worker_dispute(subdao, worker, dispute_id);

    // SubDAO resolves dispute
    subdao_governance::resolve_worker_dispute(subdao, dispute_id, resolution_status);

    // Verify resolution was recorded
    let stored_status = subdao_governance::get_dispute_status(subdao, dispute_id);
    assert(stored_status == resolution_status, "Dispute resolution failed");
}
