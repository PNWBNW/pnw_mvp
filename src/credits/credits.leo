async transition initialize_balance(user: [u8; 32]) -> bool {
    assert(!balances.contains(user));
    balances.set(user, 0u64);
    return true;
}

async transition transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> bool {
    let sender_balance: u64 = balances.get_or_use(sender, 0u64);
    
    assert(sender_balance >= amount, "Insufficient balance to complete transfer.");

    balances.set(sender, sender_balance - amount);

    let recipient_balance: u64 = balances.get_or_use(recipient, 0u64);
    balances.set(recipient, recipient_balance + amount);

    return true;
}

async transition finalize_transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> bool {
    assert(balances.contains(sender));
    assert(balances.contains(recipient));
    return true;
}

function get_balance(user: [u8; 32]) -> u64 {
    return balances.get_or_use(user, 0u64);
}
