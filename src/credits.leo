// credits.leo - Aleo program for handling ALEO (Testnet) tokens on Aleo Testnet
// This program manages test tokens for PNW_MVP, obtained via the Leo Wallet Discord faucet.

program credits.leo;  // Matches the file name credits.leo

// Define a private mapping to store ALEO (Testnet) balances for each address
mapping balance:
    // Key: Aleo address (public for identification)
    public Key as address,
    // Value: Private u64 for the balance (hidden via ZK proofs)
    private Value as u64;

// Initialize a new account with a balance of 0
transition initialize_balance(address: address):
    balance[address] = 0u64;

// Transfer ALEO (Testnet) tokens from sender to recipient
// Sender must have sufficient balance; recipient's balance increases
transition transfer(sender: address, recipient: address, amount: u64):
    // Ensure sender has enough balance
    assert_eq(balance[sender], balance[sender] + amount, "Insufficient balance");
    // Decrease sender's balance
    balance[sender] -= amount;
    // Increase recipient's balance
    balance[recipient] += amount;

// Check the balance of an address (private query for privacy)
transition get_balance(address: address) -> u64:
    return balance[address];
