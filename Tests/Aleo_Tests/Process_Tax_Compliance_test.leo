program process_tax_compliance_test.leo;

import process_tax_compliance;
import main;

//  Test: Verify Employer Tax Compliance
function test_verify_employer_tax_compliance() {
    let employer = caller();
    
    // Simulate tax payment by employer
    process_tax_compliance::record_tax_payment(employer, 5000u64);

    // Verify employer tax compliance status
    let is_compliant = process_tax_compliance::is_compliant(employer);
    assert(is_compliant == true, "Employer tax compliance verification failed");
}

//  Test: Employer Fails Tax Compliance Check
function test_employer_non_compliance() {
    let employer = caller();

    // Check compliance status without recording tax payment
    let is_compliant = process_tax_compliance::is_compliant(employer);
    
    // Employer should be non-compliant
    assert(is_compliant == false, "Employer should not be tax compliant without payment");
}

//  Test: Verify Employer Tax Compliance by ANS
function test_verify_employer_tax_by_ans() {
    let employer = caller();
    let employer_ans = "best_farm.pnw.ans";

    // Register employer ANS name
    main::ans_registry.insert(employer, employer_ans);
    main::ans_reverse_lookup.insert(employer_ans, employer);

    // Simulate tax payment
    process_tax_compliance::record_tax_payment(employer, 5000u64);

    // Verify compliance using ANS lookup
    let employer_from_ans = main::lookup_worker_by_ans(employer_ans);
    let is_compliant = process_tax_compliance::is_compliant(employer_from_ans);
    assert(is_compliant == true, "Employer tax compliance via ANS lookup failed");
}

//  Test: Verify Employer ZPass Compliance
function test_verify_employer_zpass() {
    let employer = caller();

    // Set employer as ZPass verified
    main::worker_zpass_verified.insert(employer, true);

    // Verify employer ZPass status
    let is_verified = main::worker_zpass_verified.get_or_use(employer, false);
    assert(is_verified == true, "Employer ZPass verification mismatch");
}
