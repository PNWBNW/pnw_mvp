program oversightdao_reserve.aleo {

mapping reserve_balance: [u8; 32] => u64;

const OVERSIGHT_DAO_ANS: [u8; 32] = [
    111u8, 118u8, 101u8, 114u8, 115u8, 105u8, 103u8, 104u8,
    116u8, 100u8, 97u8, 111u8, 46u8, 112u8, 110u8, 119u8,
    46u8, 97u8, 110u8, 115u8, 0u8, 0u8, 0u8, 0u8,
    0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
];

async transition deposit(oversightdao_ans: [u8; 32], amount: u64) -> Future {
    assert(amount > 0u64);
    assert(oversightdao_ans == OVERSIGHT_DAO_ANS);
    let future: Future = finalize_deposit(oversightdao_ans, amount);
    return future;
}

async function finalize_deposit(oversightdao_ans: [u8; 32], amount: u64) {
    let current_balance: u64 = reserve_balance.get_or_use(oversightdao_ans, 0u64);
    let new_balance: u64 = current_balance + amount;
    reserve_balance.set(oversightdao_ans, new_balance);
}

async transition withdraw(subdao_ans: [u8; 32], amount: u64) -> Future {
    assert(amount > 0u64);
    let future: Future = finalize_withdraw(subdao_ans, amount);
    return future;
}

async function finalize_withdraw(subdao_ans: [u8; 32], amount: u64) {
    let current_balance: u64 = reserve_balance.get_or_use(OVERSIGHT_DAO_ANS, 0u64);
    assert(current_balance >= amount);
    let new_balance: u64 = current_balance - amount;
    reserve_balance.set(OVERSIGHT_DAO_ANS, new_balance);
}

async transition validate_reserve(subdao_ans: [u8; 32]) -> Future {
    let future: Future = finalize_validate_reserve(subdao_ans);
    return future;
}

async function finalize_validate_reserve(subdao_ans: [u8; 32]) {
    assert(reserve_balance.contains(OVERSIGHT_DAO_ANS));
}

function encode_ans(ans_name: [u8; 32]) -> [u8; 32] {
    let mut hash: [u8; 32] = [0u8; 32];
    let len: u8 = if ans_name.len > 32u8 { 32u8 } else { ans_name.len };
    let i: u8 = 0u8;
    while i < len {
        hash[i] = ans_name[i];
        i = i + 1u8;
    };
    return hash;
}
}
