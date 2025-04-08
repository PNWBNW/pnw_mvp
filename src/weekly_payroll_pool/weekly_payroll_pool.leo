import aleo_std::context::*;        // For caller, block height, transaction context
import aleo_std::mapping::*;        // For dynamic mappings and set/get logic
import aleo_std::assert::*;         // For assert(...) checks
import aleo_std::crypto::*;         // For hash_poseidon, hash_blake3, etc.
import aleo_std::bytes::*;          // For byte conversions: to_bytes, from_bytes
import aleo_std::field::*;          // Field-level math: pow, invert, modular ops
import aleo_std::math::*;           // Min, max, abs, rounding functions
import aleo_std::option::*;         // For handling Option<T> (e.g., Some/None logic)
import aleo_std::result::*;         // For Result<T, E> handling, unwrap, etc.
import aleo_std::env::*;            // For reading environment variables in context
import aleo_std::string::*;         // If you're using string helpers (rare until strings are native)
import aleo_std::record::*;         // If you're using custom record types or need field flattening


async transition fund_weekly_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
    assert(amount > 0u64);

    let current_balance: u64 = weekly_balance.get_or_use(subdao_ans, 0u64);
    let new_balance: u64 = current_balance.checked_add(amount);
    weekly_balance.set(subdao_ans, new_balance);

    return true;
}

async transition execute_weekly_payroll(worker_ans: [u8; 32], subdao_ans: [u8; 32], amount: u64, zpass_hash: [u8; 64]) -> bool {
    assert(amount > 0u64);

    let weekly_funds: u64 = weekly_balance.get_or_use(subdao_ans, 0u64);
    assert(weekly_funds >= amount);

    let new_balance: u64 = weekly_funds.checked_sub(amount);
    weekly_balance.set(subdao_ans, new_balance);

    let worker_address: [u8; 32] = lookup_worker_by_ans(worker_ans);
    credits::transfer_public(worker_address, amount);

    let employer_ans: [u8; 32] = ans_reverse_lookup.get_or_use(self.caller, [0u8; 32]);
    let worker_type: u8 = worker_types.get_or_use(worker_ans, 0u8);

    if worker_type == 10u8 {
        pncw_payroll::execute_payroll(worker_ans, employer_ans, amount);
    } else if worker_type == 20u8 {
        pniw_payroll::execute_payroll(worker_ans, employer_ans, amount);
    }

    return true;
}

async transition finalize_weekly_payroll(subdao_ans: [u8; 32]) -> bool {
    assert(weekly_balance.contains(subdao_ans));
    return true;
}
