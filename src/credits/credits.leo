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

async transition initialize_balance(user: [u8; 32]) -> bool {
    assert(!balances.contains(user));
    balances.set(user, 0u64);
    return true;
}

async transition transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> bool {
    let sender_balance: u64 = balances.get_or_use(sender, 0u64);
    
    assert(sender_balance >= amount, "Insufficient balance to complete transfer.");

    balances.set(sender, sender_balance - amount);

    let recipient_balance: u64 = balances.get_or_use(recipient, 0u64);
    balances.set(recipient, recipient_balance + amount);

    return true;
}

async transition finalize_transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> bool {
    assert(balances.contains(sender));
    assert(balances.contains(recipient));
    return true;
}

function get_balance(user: [u8; 32]) -> u64 {
    return balances.get_or_use(user, 0u64);
}
