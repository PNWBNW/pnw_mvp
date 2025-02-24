program main.leo;

// Mappings
mapping worker_category: map[address, string] = {};

mapping pto_balances: map[address, u64] = {};

mapping sick_balances: map[address, u64] = {};

mapping employer_pto_funds: map[address, u64] = {};

mapping employer_sick_funds: map[address, u64] = {};

mapping last_accrual_time: map[address, u64] = {};

mapping sick_leave_used: map[address, u64] = {};

mapping farm_investments: map[address, u64] = {};

mapping worker_zpass_verified: map[address, bool] = {};

// ANS Mappings
mapping ans_registry: map[address, string] = {};

mapping ans_reverse_lookup: map[string, address] = {};

mapping subDAO_ans_registry: map[address, string] = {};

mapping subDAO_reverse_lookup: map[string, address] = {};

// Structs
struct WorkerPTO {
    worker_address: address;
    category: string;
    accrued_pto: u64;
    accrued_sick: u64;
    last_updated: u64;
}

// Function: Assign category to worker
function set_worker_category(worker: address, category: string) -> bool {
    assert(category == "General" || category == "Skilled" || category == "Agricultural" || category == "Healthcare", "Invalid category");
    
    worker_category[worker] = category;
    
    return true;
}

// Function: Accrue PTO and Sick Pay for a worker
function accrue_pto_sick_pay(worker: address, employer: address, hours_worked: u64) -> bool {
    assert(worker_zpass_verified.get(worker).unwrap_or(false), "Worker must be ZPass verified");
    
    let category = worker_category.get(worker).unwrap_or("General");
    let sick_rate: u64 = if category == "Healthcare" { 1 } else { 1 / 40 };
    let pto_rate: u64 = if category == "Agricultural" { 1 / 30 } else { 1 / 20 };
    
    let sick_accrued = hours_worked * sick_rate;
    let pto_accrued = hours_worked * pto_rate;
    
    last_accrual_time[worker] = get_current_time();
    sick_balances[worker] = sick_balances.get(worker).unwrap_or(0) + sick_accrued;
    pto_balances[worker] = pto_balances.get(worker).unwrap_or(0) + pto_accrued;
    
    if sick_balances[worker] > 40 {
        sick_balances[worker] = 40;
    }
    
    employer_sick_funds[employer] -= sick_accrued;
    employer_pto_funds[employer] -= pto_accrued;
    
    return true;
}

// Function: Worker requests PTO payout
function request_pto(worker: address, amount: u64) -> bool {
    assert(worker_zpass_verified.get(worker).unwrap_or(false), "Worker must be ZPass verified");
    assert(pto_balances.get(worker).unwrap_or(0) >= amount, "Insufficient PTO balance");
    
    pto_balances[worker] -= amount;
    transfer_private(worker, amount);
    
    return true;
}

// Function: Worker requests Sick Pay payout
function request_sick_pay(worker: address, amount: u64, verified: bool) -> bool {
    assert(worker_zpass_verified.get(worker).unwrap_or(false), "Worker must be ZPass verified");
    assert(sick_balances.get(worker).unwrap_or(0) >= amount, "Insufficient Sick Pay balance");
    
    let used_sick_leave = sick_leave_used.get(worker).unwrap_or(0);
    
    if !verified {
        assert(used_sick_leave + amount <= 40, "Unverified sick pay limited to 40 hours per year");
    }
    
    sick_balances[worker] -= amount;
    sick_leave_used[worker] += amount;
    transfer_private(worker, amount);
    
    return true;
}

// Function: Verify employer PTO/Sick Pay funding
function verify_employer_funding(employer: address) -> bool {
    assert(employer_pto_funds.get(employer).unwrap_or(0) >= 0, "Employer PTO fund deficit detected");
    assert(employer_sick_funds.get(employer).unwrap_or(0) >= 0, "Employer Sick Pay fund deficit detected");
    
    return true;
}

// Function: Lookup worker address by ANS
function lookup_worker_by_ans(ans_name: string) -> address {
    assert(ans_reverse_lookup.contains(ans_name), "Worker ANS name not found");
    
    return ans_reverse_lookup[ans_name];
}

// Function: Lookup SubDAO address by ANS
function lookup_subDAO_by_ans(ans_name: string) -> address {
    assert(subDAO_reverse_lookup.contains(ans_name), "SubDAO ANS name not found");
    
    return subDAO_reverse_lookup[ans_name];
}
