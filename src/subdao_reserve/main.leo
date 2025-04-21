import aleo_std::context::*;        // For caller, block height, transaction context
import aleo_std::mapping::*;        // For dynamic mappings and set/get logic
import aleo_std::assert::*;         // For assert(...) checks
import aleo_std::crypto::*;         // For hash_poseidon, hash_blake3, etc.
import aleo_std::bytes::*;          // For byte conversions: to_bytes, from_bytes
import aleo_std::field::*;          // Field-level math: pow, invert, modular ops
import aleo_std::math::*;           // Min, max, abs, rounding functions
import aleo_std::option::*;         // For handling Option<T>
import aleo_std::result::*;         // For Result<T, E> handling
import aleo_std::env::*;            // For environment context
import aleo_std::string::*;
import aleo_std::record::*;

import credits.aleo;
import weekly_payroll_pool.aleo;
import process_tax_compliance.aleo;

program subdao_reserve {
    mapping reserve_balance: [u8; 32] => u64;
    mapping tax_obligations: [u8; 32] => u64;

    const TAX_RATE: u64 = 10u64;

    async transition deposit(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance.get_or_use(subdao_ans, 0u64);
        let new_balance: u64 = current_balance.checked_add(amount);
        reserve_balance.set(subdao_ans, new_balance);

        return true;
    }

    async transition process_taxes(subdao_ans: [u8; 32]) -> bool {
        let current_balance: u64 = reserve_balance.get_or_use(subdao_ans, 0u64);
        assert(current_balance > 0u64);

        let tax_amount: u64 = current_balance.checked_mul(TAX_RATE).checked_div(100u64);
        let net_amount: u64 = current_balance.checked_sub(tax_amount);

        reserve_balance.set(subdao_ans, net_amount);

        let current_tax_obligation: u64 = tax_obligations.get_or_use(subdao_ans, 0u64);
        let new_tax_obligation: u64 = current_tax_obligation.checked_add(tax_amount);
        tax_obligations.set(subdao_ans, new_tax_obligation);

        credits::transfer_public(process_tax_compliance::TAX_SINK, tax_amount);
        return true;
    }

    async transition fund_weekly_payroll(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance.get_or_use(subdao_ans, 0u64);
        assert(current_balance >= amount);

        let new_balance: u64 = current_balance.checked_sub(amount);
        reserve_balance.set(subdao_ans, new_balance);

        weekly_payroll_pool::fund_weekly_pool(subdao_ans, amount);
        return true;
    }

    async transition finalize_fund_transfer(subdao_ans: [u8; 32]) -> bool {
        assert(reserve_balance.contains(subdao_ans));
        return true;
    }
}
