program oversightdao_reserve.leo;

// OversightDAO Liquidity Pool for 17% Aleo native reserve

// Constants
const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
const OVERSIGHT_ALLOCATION: u64 = 17; // 17% allocation to OversightDAO

// Mappings
mapping oversight_balance: map[address, u64] = {}; // OversightDAO balance storage

// Function: Deposit employer contributions (100% Aleo native)
function deposit_aleo_native(employer: address, amount: u64) -> bool {
    assert(amount > 0, "Deposit amount must be greater than zero");
    
    let current_balance = oversight_balance.get_or_use(OVERSIGHT_DAO, 0u64);
    oversight_balance[OVERSIGHT_DAO] = current_balance + amount;
    
    return true;
}

// Function: Withdraw from OversightDAO pool
function withdraw_for_oversight(amount: u64) -> bool {
    let current_balance = oversight_balance.get_or_use(OVERSIGHT_DAO, 0u64);
    
    assert(current_balance >= amount, "Insufficient balance in OversightDAO reserve");
    
    oversight_balance[OVERSIGHT_DAO] = current_balance - amount;
    
    return true;
}

// Function: Get OversightDAO balance
function get_oversight_balance() -> u64 {
    return oversight_balance.get_or_use(OVERSIGHT_DAO, 0u64);
}
