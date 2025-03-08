program credits.leo {
    mapping balances: [u8; 32] => u64;

    async transition initialize_balance(user: [u8; 32]) -> bool {
        Mapping::set(balances, user, 0u64);
        return true;
    }

    async transition transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> bool {
        let sender_balance: u64 = Mapping::get_or_use(balances, sender, 0u64);
        
        assert(sender_balance >= amount, "Insufficient balance to complete transfer.");

        Mapping::set(balances, sender, sender_balance - amount);

        let recipient_balance: u64 = Mapping::get_or_use(balances, recipient, 0u64);
        Mapping::set(balances, recipient, recipient_balance + amount);

        return true;
    }

    async transition get_balance(user: [u8; 32]) -> u64 {
        return Mapping::get_or_use(balances, user, 0u64);
    }
}
