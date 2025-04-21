import credits.aleo;

import aleo_std::context::*;        // For caller, block height, transaction context
import aleo_std::mapping::*;        // For dynamic mappings and set/get logic
import aleo_std::assert::*;         // For assert(...) checks
import aleo_std::crypto::*;         // For hash_poseidon, hash_blake3, etc.
import aleo_std::bytes::*;          // For byte conversions: to_bytes, from_bytes
import aleo_std::field::*;          // Field-level math: pow, invert, modular ops
import aleo_std::math::*;           // Min, max, abs, rounding functions
import aleo_std::option::*;         // For handling Option<T>
import aleo_std::result::*;         // For Result<T, E> handling
import aleo_std::env::*;            // For reading environment variables
import aleo_std::string::*;         // For string helpers
import aleo_std::record::*;         // For custom record types

program oversightdao_reserve {
    mapping reserve_balance: [u8; 32] => u64;

    const OVERSIGHT_DAO_ANS: [u8; 32] = encode_ans(b"oversightdao.pnw.ans");

    function encode_ans(ans_name: bytes) -> [u8; 32] {
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
}
