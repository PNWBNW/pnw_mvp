// Process Tax Compliance Test
program process_tax_compliance_test.aleo;

import process_tax_compliance;

// ✅ Test: Verify Employer Tax Compliance
function test_verify_employer_tax_compliance() {
    let employer = aleo::account::new();
    
    // Simulate tax payment by employer
    process_tax_compliance::record_tax_payment(employer, 5000u64);

    // Verify employer tax compliance status
    let is_compliant = process_tax_compliance::is_employer_tax_compliant(employer);
    assert(is_compliant == true, "Employer tax compliance verification failed");
}

// ✅ Test: Employer Fails Tax Compliance Check
function test_employer_non_compliance() {
    let employer = aleo::account::new();

    // Check compliance status without recording tax payment
    let is_compliant = process_tax_compliance::is_employer_tax_compliant(employer);
    
    // Employer should be non-compliant
    assert(is_compliant == false, "Employer should not be tax compliant without payment");
}
