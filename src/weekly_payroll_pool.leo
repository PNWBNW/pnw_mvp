import credits.aleo;
import subdao_reserve.aleo;
import main.aleo;
import pncw_payroll.aleo;
import pniw_payroll.aleo;

program weekly_payroll_pool.aleo {
    mapping weekly_balance: [u8; 32] => u64;

    async transition fund_weekly_pool(subdao_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);

        let current_balance: u64 = Mapping::get_or_use(weekly_balance, subdao_ans, 0u64);
        let new_balance: u64 = current_balance.checked_add(amount);
        Mapping::set(weekly_balance, subdao_ans, new_balance);

        return (true, fund_weekly_pool);
    }

    async transition execute_weekly_payroll(worker_ans: [u8; 32], subdao_ans: [u8; 32], amount: u64, zpass_hash: [u8; 64]) 
        -> (bool, async transition) {
        assert(amount > 0u64);

        let weekly_funds: u64 = Mapping::get_or_use(weekly_balance, subdao_ans, 0u64);
        assert(weekly_funds >= amount);

        let new_balance: u64 = weekly_funds.checked_sub(amount);
        Mapping::set(weekly_balance, subdao_ans, new_balance);

        credits.aleo::transfer_public(main.aleo::lookup_worker_by_ans(worker_ans), amount);

        let employer_ans: [u8; 32] = Mapping::get_or_use(main.aleo::ans_reverse_lookup, self.caller, [0u8; 32]);
        let worker_type: u8 = Mapping::get_or_use(main.aleo::worker_type, worker_ans, 0u8);

        if worker_type == 0u8 {
            pncw_payroll.aleo::execute_payroll(worker_ans, employer_ans, amount);
        } else if worker_type == 1u8 {
            pniw_payroll.aleo::execute_payroll(worker_ans, employer_ans, amount);
        }

        return (true, execute_weekly_payroll);
    }
}
