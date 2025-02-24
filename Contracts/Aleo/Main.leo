program main.leo;

// Mappings
mapping worker_category: map[address, string] = {};
mapping worker_zpass_verified: map[address, bool] = {};

// ANS Mappings
mapping ans_registry: map[address, string] = {};
mapping ans_reverse_lookup: map[string, address] = {};
mapping subDAO_ans_registry: map[address, string] = {};
mapping subDAO_reverse_lookup: map[string, address] = {};

// SubDAO and OversightDAO Reserve Wallets
const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
const OVERSIGHT_ALLOCATION: u64 = 17; // 17% allocation to OversightDAO

// Structs
struct Worker {
    worker_address: address;
    category: string;
    last_updated: u64;
}

// Function: Assign category to worker
function set_worker_category(worker: address, category: string) -> bool {
    assert(category == "General" || category == "Skilled" || category == "Agricultural" || category == "Healthcare", "Invalid category");
    worker_category[worker] = category;
    return true;
}

// Function: Allocate funds to OversightDAO
function allocate_to_oversight(amount: u64) -> bool {
    assert(amount > 0, "Allocation amount must be greater than zero");
    
    let current_balance = payroll_pools::get_payroll_balance();
    let oversight_amount = current_balance * OVERSIGHT_ALLOCATION / 100u64;
    
    assert(current_balance >= oversight_amount, "Insufficient balance for oversight allocation");
    
    payroll_pools::withdraw_for_payroll(SUBDAO_RESERVE, oversight_amount);
    payroll_pools::deposit_aleo_native(OVERSIGHT_DAO, oversight_amount);
    
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
