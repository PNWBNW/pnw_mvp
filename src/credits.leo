program credits.leo {
    mapping balances: address => u64;

    transition initialize_balance(user: address) {
        Mapping::set(balances, user, 0u64);
    }

    transition transfer(sender: address, recipient: address, amount: u64) {
        let sender_balance = Mapping::get_or_use(balances, sender, 0u64);
        assert(sender_balance >= amount, "Insufficient balance");

        Mapping::set(balances, sender, sender_balance - amount);

        let recipient_balance = Mapping::get_or_use(balances, recipient, 0u64);
        Mapping::set(balances, recipient, recipient_balance + amount);
    }

    transition get_balance(user: address) -> u64 {
        return Mapping::get_or_use(balances, user, 0u64);
    }
}
