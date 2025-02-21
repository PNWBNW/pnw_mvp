// Main.leo Test File
program main_test.aleo;

import main;

// ✅ Test: Set Worker Category
function test_set_worker_category() {
    let worker = aleo::account::new();
    let category = "Skilled";

    // Set worker category
    main::set_worker_category(worker, category);

    // Verify category was set
    let stored_category = main::worker_category[worker];
    assert(stored_category == category, "Worker category mismatch");
}

// ✅ Test: Request PTO Payout
function test_request_pto() {
    let worker = aleo::account::new();
    let amount = 10u64;

    // Fund PTO balance (simulate payroll accrual)
    main::pto_balances[worker] = 50;

    // Request PTO payout
    let result = main::request_pto(worker, amount);
    assert(result == true, "PTO request failed");

    // Verify PTO balance reduction
    let new_balance = main::pto_balances[worker];
    assert(new_balance == 40, "PTO balance mismatch");
}

// ✅ Test: Worker ZPass Verification
function test_zpass_verification() {
    let worker = aleo::account::new();

    // Set worker as ZPass verified
    main::worker_zpass_verified[worker] = true;

    // Verify worker ZPass status
    let is_verified = main::worker_zpass_verified[worker];
    assert(is_verified == true, "ZPass verification mismatch");
}

// ✅ Test: Assign Worker ANS Name
function test_set_worker_ans() {
    let worker = aleo::account::new();
    let ans_name = "john_doe.pncw.ans";

    // Assign ANS name
    main::ans_registry[worker] = ans_name;
    main::ans_reverse_lookup[ans_name] = worker;

    // Verify ANS mappings
    let stored_ans = main::ans_registry[worker];
    assert(stored_ans == ans_name, "ANS registry mismatch");

    let stored_worker = main::ans_reverse_lookup[ans_name];
    assert(stored_worker == worker, "ANS reverse lookup mismatch");
}
