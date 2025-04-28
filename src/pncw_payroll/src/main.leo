program pncw_payroll {

import employer_agreement.aleo;
import subdao_reserve.aleo;
import credits.aleo;

mapping employer_funding: [u8; 32] => u32;
mapping worker_balances: [u8; 32] => u32;

function lookup_worker_by_ans(worker_ans: [u8; 32]) -> [u8; 32] {
    return worker_ans;
}

async transition fund_payroll(employer_ans: [u8; 32], amount: u32) -> bool {
    assert(amount > 0u32);

    let is_registered: bool = employer_agreement::employer_registry.get_or_use(employer_ans, false);
    assert(is_registered);

    let is_compliant: bool = employer_agreement::employer_tax_compliance.get_or_use(employer_ans, false);
    assert(is_compliant);

    let current_funding: u32 = employer_funding.get_or_use(employer_ans, 0u32);
    let new_funding: u32 = current_funding + amount;
    employer_funding.set(employer_ans, new_funding);

    let subdao_ans: [u8; 32] = subdao_reserve::SUBDAO_RESERVE_ANS;
    subdao_reserve::deposit(subdao_ans, amount);

    return true;
}

async transition execute_payroll(worker_ans: [u8; 32], employer_ans: [u8; 32], amount: u32) -> bool {
    assert(amount > 0u32);

    let worker_type: u8 = employer_agreement::worker_type.get_or_use(worker_ans, 0u8);
    assert(worker_type != 0u8);

    let current_funding: u32 = employer_funding.get_or_use(employer_ans, 0u32);
    assert(current_funding >= amount);

    let updated_funding: u32 = current_funding - amount;
    employer_funding.set(employer_ans, updated_funding);

    let worker_balance: u32 = worker_balances.get_or_use(worker_ans, 0u32);
    let updated_balance: u32 = worker_balance + amount;
    worker_balances.set(worker_ans, updated_balance);

    let worker_address: [u8; 32] = lookup_worker_by_ans(worker_ans);
    credits::transfer_public(worker_address, amount);

    return true;
}

async transition finalize_payroll(worker_ans: [u8; 32]) -> bool {
    let exists: bool = worker_balances.contains(worker_ans);
    assert(exists);

    return true;
}

function verify_worker_balance(worker_ans: [u8; 32]) -> u32 {
    return worker_balances.get_or_use(worker_ans, 0u32);
}
