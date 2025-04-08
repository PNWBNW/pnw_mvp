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


async transition fund_payroll(employer_ans: [u8; 32], amount: u64) -> bool {
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
    assert(amount > 0u64);
    assert(worker_type.get_or_use(worker_ans, 0u8) != 0u8);

    let current_funding: u64 = employer_funding.get_or_use(employer_ans, 0u64);
    assert(current_funding >= amount);

    let updated_funding: u64 = current_funding.checked_sub(amount);
    employer_funding.set(employer_ans, updated_funding);

    let worker_balance: u64 = worker_balances.get_or_use(worker_ans, 0u64).checked_add(amount);
    worker_balances.set(worker_ans, worker_balance);

    let worker_address: [u8; 32] = lookup_worker_by_ans(worker_ans);
    credits::transfer_public(worker_address, amount);

    return true;
}

async transition finalize_payroll(worker_ans: [u8; 32]) -> bool {
    assert(worker_balances.contains(worker_ans));
    return true;
}

function verify_worker_balance(worker_ans: [u8; 32]) -> u64 {
    return worker_balances.get_or_use(worker_ans, 0u64);
}
