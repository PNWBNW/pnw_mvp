// Employer Agreement Test
program employer_agreement_test.aleo;

import employer_agreement;
import main;  // Importing ANS and ZPass from main.leo

// ✅ Test: Employer Signs Agreement & Meets Compliance
function test_employer_agreement_signing() {
    let employer = aleo::account::new();

    // Employer signs agreement
    employer_agreement::sign_agreement(employer);

    // Verify agreement status
    let has_signed = employer_agreement::has_signed_agreement(employer);
    assert(has_signed == true, "Employer agreement signing failed");
}

// ✅ Test: Employer Certification Compliance
function test_employer_certification_compliance() {
    let employer = aleo::account::new();
    let certification = "Fair Trade";

    // Assign certification
    employer_agreement::assign_certification(employer, certification);

    // Verify certification was assigned
    let stored_certification = employer_agreement::get_certification(employer);
    assert(stored_certification == certification, "Employer certification mismatch");
}

// ✅ Test: Employer Signs Agreement Using ANS
function test_employer_agreement_by_ans() {
    let employer = aleo::account::new();
    let employer_ans = "ethical_farm.pnw.ans";

    // Assign ANS name
    main::ans_registry[employer] = employer_ans;
    main::ans_reverse_lookup[employer_ans] = employer;

    // Sign agreement using ANS lookup
    let employer_from_ans = main::lookup_worker_by_ans(employer_ans);
    employer_agreement::sign_agreement(employer_from_ans);

    // Verify agreement status
    let has_signed = employer_agreement::has_signed_agreement(employer_from_ans);
    assert(has_signed == true, "Employer agreement signing via ANS failed");
}

// ✅ Test: Verify Employer ZPass Status
function test_employer_zpass_verification() {
    let employer = aleo::account::new();

    // Set employer as ZPass verified
    main::worker_zpass_verified[employer] = true;

    // Verify employer ZPass status
    let is_verified = main::worker_zpass_verified[employer];
    assert(is_verified == true, "Employer ZPass verification failed");
}
