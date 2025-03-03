import credits.aleo;

program oversightDAO_reserve.aleo {
    mapping reserve_balance: [u8; 32] => u64;

    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";

    async transition deposit(oversightDAO_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);
        assert(oversightDAO_ans == OVERSIGHT_DAO_ANS);

        let current_balance: u64 = reserve_balance[oversightDAO_ans];
        let new_balance: u64 = current_balance.checked_add(amount);
        Mapping::set(reserve_balance, oversightDAO_ans, new_balance);

        return (true, deposit);
    }

    async transition withdraw(subdao_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance[OVERSIGHT_DAO_ANS];
        assert(current_balance >= amount);

        let new_balance: u64 = current_balance.checked_sub(amount);
        Mapping::set(reserve_balance, OVERSIGHT_DAO_ANS, new_balance);

        credits.aleo::transfer_public(subdao_ans, amount);
        return (true, withdraw);
    }

    function get_reserve_balance() -> u64 {
        return reserve_balance[OVERSIGHT_DAO_ANS];
    }
}
