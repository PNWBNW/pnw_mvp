async transition deposit(oversightdao_ans: [u8; 32], amount: u64) -> bool {
    assert(amount > 0u64);
    assert(oversightdao_ans == OVERSIGHT_DAO_ANS);

    let current_balance: u64 = reserve_balance.get_or_use(oversightdao_ans, 0u64);
    let new_balance: u64 = current_balance.checked_add(amount);

    reserve_balance.set(oversightdao_ans, new_balance);
    return true;
}

async transition withdraw(subdao_ans: [u8; 32], amount: u64) -> bool {
    assert(amount > 0u64);

    let current_balance: u64 = reserve_balance.get_or_use(OVERSIGHT_DAO_ANS, 0u64);
    assert(current_balance >= amount, "Insufficient reserve balance.");

    let new_balance: u64 = current_balance.checked_sub(amount);
    reserve_balance.set(OVERSIGHT_DAO_ANS, new_balance);

    credits.aleo::transfer_public(subdao_ans, amount);
    return true;
}

async transition finalize_withdraw(subdao_ans: [u8; 32], amount: u64) -> bool {
    assert(reserve_balance.contains(OVERSIGHT_DAO_ANS));
    return true;
}
