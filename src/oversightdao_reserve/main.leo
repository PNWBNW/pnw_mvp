program oversightdao_reserve;

import context.leo;
import mapping.leo;
import assert.leo;
import crypto.leo;
import bytes.leo;
import field.leo;
import math.leo;
import option.leo;
import result.leo;
import env.leo;
import record.leo;

mapping reserve_balance: [u8; 32] => u64;

const OVERSIGHT_DAO_ANS: [u8; 32] = encode_ans(b"oversightdao.pnw.ans");

function encode_ans(ans_name: bytes) -> [u8; 32] {
    hash_arc721(ans_name)
}

transition deposit(oversightdao_ans: [u8; 32], amount: u64) -> bool {
    assert(amount > 0u64);
    assert(oversightdao_ans == OVERSIGHT_DAO_ANS);

    let current_balance: u64 = reserve_balance.get_or_use(oversightdao_ans, 0u64);
    let new_balance: u64 = current_balance.checked_add(amount);

    reserve_balance.set(oversightdao_ans, new_balance);
    true
}

transition withdraw(subdao_ans: [u8; 32], amount: u64) -> bool {
    assert(amount > 0u64);

    let current_balance: u64 = reserve_balance.get_or_use(OVERSIGHT_DAO_ANS, 0u64);
    assert(current_balance >= amount);

    let new_balance: u64 = current_balance.checked_sub(amount);
    reserve_balance.set(OVERSIGHT_DAO_ANS, new_balance);

    true
}

transition finalize_withdraw(subdao_ans: [u8; 32], amount: u64) -> bool {
    assert(reserve_balance.contains(OVERSIGHT_DAO_ANS));
    true
}
