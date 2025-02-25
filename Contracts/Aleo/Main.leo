import credits.aleo;
import payroll_pools;

program main.leo {

// Mappings
mapping worker_category: map[address, [u8; 20]] = {};
mapping worker_zpass_verified: map[address, bool] = {};

// ANS Mappings
mapping ans_registry: map[address, [u8; 20]] = {};
mapping ans_reverse_lookup: map<[u8; 20], address] = {};
mapping subDAO_ans_registry: map[address, [u8; 20]] = {};
mapping subDAO_reverse_lookup: map<[u8; 20], address] = {};

// SubDAO and OversightDAO Reserve Wallets
const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
const OVERSIGHT_ALLOCATION: u64 = 17; // 17% allocation to OversightDAO

// Structs
struct Worker {
    worker_address: address;
    category: [u8; 20];
    last_updated: u64;
}

// Function: Assign category to worker
function set_worker_category(worker: address, category: [u8; 20]) -> bool {
    let valid_categories: [[u8; 20]; 4] = [
        *b"General             ",
        *b"Skilled             ",
        *b"Agricultural        ",
        *b"Healthcare          "
    ];
    
    for i in 0..4u8 {
        if category == valid_categories[i] {
            worker_category[worker] = category;
            return true;
        }
    }
    assert(false, "Invalid category");
    return false;
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

// Function: Lookup worker address by ANS using API
async function lookup_worker_by_ans(ans_name: [u8; 20]) -> address {
    let response = fetch("https://testnet-api.aleonames.id/address/" + ans_name);
    let worker_address: address = response.json().address;
    assert(worker_address != 0x0, "Worker ANS name not found");
    return worker_address;
}

// Function: Lookup SubDAO address by local registry
function lookup_subDAO_by_ans(ans_name: [u8; 20]) -> address {
    assert(subDAO_reverse_lookup.contains(ans_name), "SubDAO ANS name not found");
    return subDAO_reverse_lookup[ans_name];
}

}
