program oversightdao_reserve.leo {
    mapping reserve_balance: [u8; 32] => u64;

    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";

    async transition deposit(oversightdao_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);
        assert(oversightdao_ans == OVERSIGHT_DAO_ANS);

        let current_balance: u64 = Mapping::get_or_use(reserve_balance, oversightdao_ans, 0u64);
        let new_balance: u64 = current_balance.checked_add(amount);
        Mapping::set(reserve_balance, oversightdao_ans, new_balance);

        return (true, deposit);
    }

    async transition withdraw(subdao_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);

        let current_balance: u64 = Mapping::get_or_use(reserve_balance, OVERSIGHT_DAO_ANS, 0u64);
        assert(current_balance >= amount);

        let new_balance: u64 = current_balance.checked_sub(amount);
        Mapping::set(reserve_balance, OVERSIGHT_DAO_ANS, new_balance);

        credits.leo::transfer_public(subdao_ans, amount);
        return (true, withdraw);
    }
}
