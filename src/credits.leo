program credits.leo {
    mapping balances: [u8; 32] => u64;

    async transition initialize_balance(user: [u8; 32]) -> (bool, async transition) {
        Mapping::set(balances, user, 0u64);
        return (true, initialize_balance);
    }

    async transition transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> (bool, async transition) {
        let sender_balance: u64 = Mapping::get(balances, sender).unwrap_or(0u64);
        assert(sender_balance >= amount, "Insufficient balance");

        Mapping::set(balances, sender, sender_balance - amount);

        let recipient_balance: u64 = Mapping::get(balances, recipient).unwrap_or(0u64);
        Mapping::set(balances, recipient, recipient_balance + amount);

        return (true, transfer);
    }

    function get_balance(user: [u8; 32]) -> u64 {
        return Mapping::get(balances, user).unwrap_or(0u64);
    }
}
