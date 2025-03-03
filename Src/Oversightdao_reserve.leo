import credits.aleo;

program oversightDAO_reserve.aleo {
    // Mapping
    mapping reserve_balance: address => u64;

    // Constants
    const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";

    // Transition: Deposit funds into OversightDAO reserve
    transition deposit(oversightDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);
        assert(oversightDAO == OVERSIGHT_DAO);

        let current_balance: u64 = reserve_balance[oversightDAO];
        let new_balance: u64 = current_balance.checked_add(amount);
        reserve_balance[oversightDAO] = new_balance;

        return true;
    }

    // Transition: Withdraw funds for SubDAO use (future feature)
    transition withdraw(subDAO: address, amount: u64) -> bool {
        assert(amount > 0u64);

        let current_balance: u64 = reserve_balance[OVERSIGHT_DAO];
        let new_balance: u64 = current_balance.checked_sub(amount);
        reserve_balance[OVERSIGHT_DAO] = new_balance;

        credits.aleo::transfer_public(subDAO, amount);
        return true;
    }

    // Function: Get OversightDAO reserve balance
    function get_reserve_balance() -> u64 {
        return reserve_balance[OVERSIGHT_DAO];
    }
}
