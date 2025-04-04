import aleo_std.hashes.poseidon::*;

program credits {
    mapping balances: [u8; 32] => u64;

    // Initializes the balance of an account
    transition initialize_balance(account: [u8; 32]) -> bool {
        balances[account] = 0u64;
        return true;
    }

    // Handles token transfers securely
    transition transfer(sender: [u8; 32], recipient: [u8; 32], amount: u64) -> bool {
        assert(balances[sender] >= amount, "Insufficient funds");
        balances[sender] -= amount;
        balances[recipient] += amount;
        return true;
    }

    // Utility for hashing accounts for mappings
    function hash_account(account: address) -> [u8; 32] {
        return hash_poseidon(account);
    }
}
