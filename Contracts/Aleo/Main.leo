program payroll_pool.leo;

// Payroll Pool Mappings
mapping payroll_balance: map[address, u64] = {};  // Singular payroll pool
mapping employer_obligations: map[address, u64] = {};  // Employer payroll obligations

// Constants
const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
const OVERSIGHT_ALLOCATION: u64 = 17; // 17% allocation to OversightDAO

// Function: Deposit Aleo native tokens into the payroll pool
function deposit_aleo_native(employer: address, amount: u64) -> bool {
    assert(amount > 0, "Deposit amount must be greater than zero");
    
    let current_balance = payroll_balance.get_or_use(SUBDAO_RESERVE, 0u64);
    payroll_balance[SUBDAO_RESERVE] = current_balance + amount;
    
    return true;
}

// Function: Withdraw from payroll pool for payroll processing
function withdraw_for_payroll(employer: address, amount: u64) -> bool {
    let current_balance = payroll_balance.get_or_use(SUBDAO_RESERVE, 0u64);
    let employer_obligation = employer_obligations.get_or_use(employer, 0u64);
    
    assert(current_balance >= amount, "Insufficient balance in payroll pool");
    
    // Deduct from payroll pool
    payroll_balance[SUBDAO_RESERVE] = current_balance - amount;
    
    return true;
}

// Function: Allocate a percentage of payroll funds to OversightDAO
function allocate_to_oversight() -> bool {
    let current_balance = payroll_balance.get_or_use(SUBDAO_RESERVE, 0u64);
    let oversight_amount = current_balance * OVERSIGHT_ALLOCATION / 100u64;
    
    assert(current_balance >= oversight_amount, "Insufficient balance for oversight allocation");
    
    payroll_balance[SUBDAO_RESERVE] -= oversight_amount;
    payroll_balance[OVERSIGHT_DAO] += oversight_amount;
    
    return true;
}

// Function: Set employer payroll obligation
function set_employer_obligation(employer: address, obligation: u64) -> bool {
    employer_obligations[employer] = obligation;
    return true;
}

// Function: Get payroll balance
function get_payroll_balance() -> u64 {
    return payroll_balance.get_or_use(SUBDAO_RESERVE, 0u64);
}
