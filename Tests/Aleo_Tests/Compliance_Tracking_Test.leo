// Compliance Tracking Test
program compliance_tracking_test.aleo;

import compliance_tracking;

// ✅ Test: Verify Employer Compliance
function test_employer_compliance() {
    let employer = aleo::account::new();

    // Simulate setting compliance status
    compliance_tracking::set_employer_compliance(employer, true);

    // Verify employer is compliant
    let is_compliant = compliance_tracking::is_employer_compliant(employer);
    assert(is_compliant == true, "Employer compliance check failed");
}

// ✅ Test: Verify Worker Certification Compliance
function test_worker_certification() {
    let worker = aleo::account::new();
    let certification = "USDA Organic";

    // Assign worker certification
    compliance_tracking::assign_worker_certification(worker, certification);

    // Verify certification was assigned
    let stored_certification = compliance_tracking::get_worker_certification(worker);
    assert(stored_certification == certification, "Worker certification mismatch");
}

// ✅ Test: Verify Worker ZPass Compliance
function test_worker_zpass_compliance() {
    let worker = aleo::account::new();

    // Set worker as ZPass verified
    compliance_tracking::set_worker_zpass(worker, true);

    // Verify worker compliance
    let is_verified = compliance_tracking::is_worker_zpass_verified(worker);
    assert(is_verified == true, "Worker ZPass compliance check failed");
}
