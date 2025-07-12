program pniw_payroll.aleo;

import aleo_gas_station.aleo;
import payroll_audit_log.aleo;

struct PayrollRequest {
    employer_hash: field,
    worker_hash: field,
    amount: u64,
    duration_days: u16,
    block_height: u32,
}

mapping employer_funding: field => u64;
mapping worker_balances: field => u64;

async transition fund_payroll(employer_hash: field, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_fund_payroll(employer_hash, amount);
    return future;
}

async function finalize_fund_payroll(employer_hash: field, amount: u64) {
    let current: u64 = employer_funding.get_or_use(employer_hash, 0u64);
    let updated: u64 = current + amount;
    employer_funding.set(employer_hash, updated);
}

async transition execute_payroll(
    employer_hash: field,
    worker_hash: field,
    amount: u64,
    duration_days: u16
) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_execute_payroll(employer_hash, worker_hash, amount, duration_days);
    return future;
}

async function finalize_execute_payroll(
    employer_hash: field,
    worker_hash: field,
    amount: u64,
    duration_days: u16
) {
    let current_funding: u64 = employer_funding.get_or_use(employer_hash, 0u64);
    assert(current_funding >= amount);

    let new_funding: u64 = current_funding - amount;
    employer_funding.set(employer_hash, new_funding);

    let balance: u64 = worker_balances.get_or_use(worker_hash, 0u64);
    worker_balances.set(worker_hash, balance + amount);

    // Placeholder hash logic
    let payment_data: [u64; 3] = [amount, block.height, duration_days as u64];
    let payment_hash: field = Poseidon2::hash(payment_data);

    async payroll_audit_log/record_payment_hash(payment_hash, block.height);

    // Optional: Hook to coordinator to trigger Stellar USDC payout
    // This would call coordinator_program::dispatch_payout(...)
}

async transition verify_worker_balance(worker_hash: field) -> Future {
    let future: Future = finalize_verify_worker_balance(worker_hash);
    return future;
}

async function finalize_verify_worker_balance(worker_hash: field) {
    assert(worker_balances.contains(worker_hash));
}

async transition get_worker_balance(worker_hash: field) -> Future {
    let future: Future = finalize_get_worker_balance(worker_hash);
    return future;
}

async function finalize_get_worker_balance(worker_hash: field) {
    let balance: u64 = worker_balances.get_or_use(worker_hash, 0u64);
    // Hook to frontend (optional)
}
