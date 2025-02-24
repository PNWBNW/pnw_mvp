program main.leo;

// Mappings
mapping worker_category: map[address, string] = {};

mapping worker_zpass_verified: map[address, bool] = {};

// ANS Mappings
mapping ans_registry: map[address, string] = {};

mapping ans_reverse_lookup: map[string, address] = {};

mapping subDAO_ans_registry: map[address, string] = {};

mapping subDAO_reverse_lookup: map[string, address] = {};

// SubDAO Reserve Wallet
const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;

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
