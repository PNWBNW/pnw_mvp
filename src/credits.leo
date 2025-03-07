program credits.leo {
    mapping balances: address => u64;

    async transition initialize_balance(user: address) -> (bool, async transition) {
        Mapping::set(balances, user, 0u64);
        return (true, initialize_balance);
    }

    async transition transfer(sender: address, recipient: address, amount: u64) -> (bool, async transition) {
        let sender_balance = Mapping::get_or_use(balances, sender, 0u64);
        assert(sender_balance >= amount, "Insufficient balance");

        Mapping::set(balances, sender, sender_balance - amount);

        let recipient_balance = Mapping::get_or_use(balances, recipient, 0u64);
        Mapping::set(balances, recipient, recipient_balance + amount);

        return (true, transfer);
    }

    transition get_balance(user: address) -> u64 {
        return Mapping::get_or_use(balances, user, 0u64);
    }
}
