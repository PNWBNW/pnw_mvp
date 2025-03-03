import credits.aleo;

program oversightDAO_reserve.aleo {
    // Mapping
    mapping reserve_balance: [u8; 32] => u64; // Uses OversightDAO ANS instead of address

    // Constants
    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";

    // Transition: Deposit funds into OversightDAO reserve
    transition deposit(oversightDAO_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);
        assert(oversightDAO_ans == OVERSIGHT_DAO_ANS);

        let current_balance: u64 = reserve_balance[oversightDAO_ans];
        let new_balance: u64 = current_balance.checked_add(amount);
        reserve_balance[oversightDAO_ans] = new_balance;

        return true;
    }

    // Transition: Withdraw funds for SubDAO use
    transition withdraw(subdao_ans: [u8; 32], amount: u64) -> bool {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance[OVERSIGHT_DAO_ANS];
        assert(current_balance >= amount);

        let new_balance: u64 = current_balance.checked_sub(amount);
        reserve_balance[OVERSIGHT_DAO_ANS] = new_balance;

        credits.aleo::transfer_public(subdao_ans, amount);
        return true;
    }

    // Function: Get OversightDAO reserve balance
    function get_reserve_balance() -> u64 {
        return reserve_balance[OVERSIGHT_DAO_ANS];
    }
}
