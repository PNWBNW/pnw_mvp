program weekly_payroll_pool.aleo {

mapping weekly_balance: address => u64;

async transition fund_weekly_pool(subdao_address: address, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_fund_weekly_pool(subdao_address, amount);
    return future;
}

async function finalize_fund_weekly_pool(subdao_address: address, amount: u64) {
    let current_balance: u64 = weekly_balance.get_or_use(subdao_address, 0u64);
    let new_balance: u64 = current_balance + amount;

    weekly_balance.set(subdao_address, new_balance);
}

async transition execute_weekly_payroll(subdao_address: address, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_execute_weekly_payroll(subdao_address, amount);
    return future;
}

async function finalize_execute_weekly_payroll(subdao_address: address, amount: u64) {
    let current_balance: u64 = weekly_balance.get_or_use(subdao_address, 0u64);
    assert(current_balance >= amount);

    let new_balance: u64 = current_balance - amount;
    weekly_balance.set(subdao_address, new_balance);
}

async transition verify_pool_exists(subdao_address: address) -> Future {
    let future: Future = finalize_verify_pool_exists(subdao_address);
    return future;
}

async function finalize_verify_pool_exists(subdao_address: address) {
    assert(weekly_balance.contains(subdao_address));
}
}
