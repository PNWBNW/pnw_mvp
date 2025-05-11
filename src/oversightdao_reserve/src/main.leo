program oversightdao_reserve.aleo {

mapping reserve_balance: address => u64;

async transition deposit(dao_address: address, amount: u64) -> Future {
    assert(amount > 0u64);
    let future: Future = finalize_deposit(dao_address, amount);
    return future;
}

async function finalize_deposit(dao_address: address, amount: u64) {
    let current_balance: u64 = reserve_balance.get_or_use(dao_address, 0u64);
    let new_balance: u64 = current_balance + amount;
    reserve_balance.set(dao_address, new_balance);
}

async transition withdraw(dao_address: address, amount: u64) -> Future {
    assert(amount > 0u64);
    let future: Future = finalize_withdraw(dao_address, amount);
    return future;
}

async function finalize_withdraw(dao_address: address, amount: u64) {
    let current_balance: u64 = reserve_balance.get_or_use(dao_address, 0u64);
    assert(current_balance >= amount);
    let new_balance: u64 = current_balance - amount;
    reserve_balance.set(dao_address, new_balance);
}

async transition validate_reserve(dao_address: address) -> Future {
    let future: Future = finalize_validate_reserve(dao_address);
    return future;
}

async function finalize_validate_reserve(dao_address: address) {
    assert(reserve_balance.contains(dao_address));
}
}
