program pncw_payroll.aleo {

import employer_agreement.aleo;
import subdao_reserve.aleo;
import credits.aleo;
program pncw_payroll.aleo {

mapping employer_funding: address => u64;
mapping worker_balances: address => u64;

async transition fund_payroll(employer: address, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_fund_payroll(employer, amount);
    return future;
}

async function finalize_fund_payroll(employer: address, amount: u64) {
    let current_funding: u64 = employer_funding.get_or_use(employer, 0u64);
    let new_funding: u64 = current_funding + amount;

    employer_funding.set(employer, new_funding);
}

async transition execute_payroll(worker: address, employer: address, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_execute_payroll(worker, employer, amount);
    return future;
}

async function finalize_execute_payroll(worker: address, employer: address, amount: u64) {
    let current_funding: u64 = employer_funding.get_or_use(employer, 0u64);
    assert(current_funding >= amount);

    let updated_funding: u64 = current_funding - amount;
    employer_funding.set(employer, updated_funding);

    let worker_balance: u64 = worker_balances.get_or_use(worker, 0u64);
    let updated_balance: u64 = worker_balance + amount;
    worker_balances.set(worker, updated_balance);

    // --- HOOK READY ---
    // The coordinator_program will later call:
    // credits::transfer_public(worker, amount)
    // payroll_audit_log::record_payment(worker, amount, block_height)
    // ------------------
}

async transition verify_worker_balance(worker: address) -> Future {
    let future: Future = finalize_verify_worker_balance(worker);
    return future;
}

async function finalize_verify_worker_balance(worker: address) {
    assert(worker_balances.contains(worker));
}

inline verify_worker_balance_amount(worker: address) -> u64 {
    return worker_balances.get_or_use(worker, 0u64);
}
}or_use(worker_ans, 0u32);
}
