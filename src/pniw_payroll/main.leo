import credits.aleo;
import employer_agreement.aleo;
import subdao_reserve.aleo;

import aleo_std::context::*;
import aleo_std::mapping::*;
import aleo_std::assert::*;
import aleo_std::crypto::*;
import aleo_std::bytes::*;
import aleo_std::field::*;
import aleo_std::math::*;
import aleo_std::option::*;
import aleo_std::result::*;
import aleo_std::env::*;
import aleo_std::string::*;
import aleo_std::record::*;

program pniw_payroll {
    mapping employer_funding: [u8; 32] => u64;
    mapping worker_balances: [u8; 32] => u64;

    function lookup_worker_by_ans(worker_ans: [u8; 32]) -> [u8; 32] {
        return worker_ans;
    }

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
        assert(employer_agreement::worker_type.get_or_use(worker_ans, 0u8) != 0u8);

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
}
