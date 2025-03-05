program credits.aleo;

mapping balances:
    address => u64;

function mint(recipient: address, amount: u64) -> u64 {
    let balance = balances.get_or_use(&recipient, 0u64);
    let new_balance = balance + amount;
    balances.set(&recipient, new_balance);
    return new_balance;
}

function transfer(sender: address, recipient: address, amount: u64) -> bool {
    let sender_balance = balances.get_or_use(&sender, 0u64);
    if sender_balance < amount {
        return false; // Insufficient funds
    }
    
    let new_sender_balance = sender_balance - amount;
    let recipient_balance = balances.get_or_use(&recipient, 0u64) + amount;

    balances.set(&sender, new_sender_balance);
    balances.set(&recipient, recipient_balance);

    return true;
}

function check_balance(user: address) -> u64 {
    return balances.get_or_use(&user, 0u64);
}
