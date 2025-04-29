program pniw_payroll.aleo {

import employer_agreement.aleo;
import subdao_reserve.aleo;
import time_oracle.aleo;
import payroll_audit_log.aleo;

struct DateTime {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8
}

mapping employer_funding: [u8; 32] => u64;
mapping worker_balances: [u8; 32] => u64;

function lookup_worker_by_ans(worker_ans: [u8; 32]) -> [u8; 32] {
    return worker_ans;
}

async transition fund_payroll(employer_ans: [u8; 32], amount: u64) -> bool {
    return finalize_fund_payroll(employer_ans, amount);
}

async function finalize_fund_payroll(employer_ans: [u8; 32], amount: u64) -> bool {
    assert(amount > 0u64);
    assert(employer_agreement::employer_registry.get_or_use(employer_ans, false));
    assert(employer_agreement::employer_tax_compliance.get_or_use(employer_ans, false));

    let current_funding: u64 = employer_funding.get_or_use(employer_ans, 0u64);
    let new_funding: u64 = current_funding.checked_add(amount);
    employer_funding.set(employer_ans, new_funding);

    let subdao_ans: [u8; 32] = subdao_reserve::SUBDAO_RESERVE_ANS;
    credits::transfer_public(subdao_ans, amount);
    subdao_reserve::deposit(subdao_ans, amount);

    return true;
}

async transition execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u64) -> bool {
    return finalize_execute_payroll(worker_ans, employer_ans, amount);
}

async function finalize_execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u64) -> bool {
    assert(employer_agreement::worker_type.get_or_use(worker_ans, 0u8) != 0u8);

    let current_funding: u64 = employer_funding.get_or_use(employer_ans, 0u64);
    assert(current_funding >= amount);
    let updated_funding: u64 = current_funding.checked_sub(amount);
    employer_funding.set(employer_ans, updated_funding);

    let worker_balance: u64 = worker_balances.get_or_use(worker_ans, 0u64).checked_add(amount);
    worker_balances.set(worker_ans, worker_balance);

    let worker_address: [u8; 32] = lookup_worker_by_ans(worker_ans);
    credits::transfer_public(worker_address, amount);

    // Consume previous record (simulate lifecycle burn)
    worker_balances.remove(worker_ans);

    // Timestamping via Demox time_oracle
    let height: u32 = time_oracle::block_height();
    let payment_hash: [u8; 32] = hash_to_bytes(worker_ans, height);
    payroll_audit_log::record(payment_hash, height);

    return true;
}

async transition finalize_payroll(worker_ans: [u8; 32]) -> bool {
    return finalize_finalize_payroll(worker_ans);
}

async function finalize_finalize_payroll(worker_ans: [u8; 32]) -> bool {
    assert(worker_balances.contains(worker_ans));
    return true;
}

async function verify_worker_balance(worker_ans: [u8; 32]) -> u64 {
    return worker_balances.get_or_use(worker_ans, 0u64);
}

function hash_to_bytes(worker_ans: [u8; 32], height: u32) -> [u8; 32] {
    let input: [u8; 36] = worker_ans + height.to_le_bytes();
    return hash_to_bytes(input)
}
