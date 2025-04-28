program oversightdao_reserve.aleo {

mapping reserve_balance: [u8; 32] => u64;

const OVERSIGHT_DAO_ANS: [u8; 32] = [
    111u8, 118u8, 101u8, 114u8, 115u8, 105u8, 103u8, 104u8,
    116u8, 100u8, 97u8, 111u8, 46u8, 112u8, 110u8, 119u8,
    46u8, 97u8, 110u8, 115u8, 0u8, 0u8, 0u8, 0u8,
    0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
];

finalize function encode_ans(ans_name: [u8]) -> [u8; 32] {
    return hash_arc721(ans_name);
}

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
    assert(current_balance >= amount);

    let new_balance: u64 = current_balance.checked_sub(amount);

    reserve_balance.set(OVERSIGHT_DAO_ANS, new_balance);

    return true;
}

async transition finalize_withdraw(subdao_ans: [u8; 32], amount: u64) -> bool {
    assert(reserve_balance.contains(OVERSIGHT_DAO_ANS));

    return true;
}
