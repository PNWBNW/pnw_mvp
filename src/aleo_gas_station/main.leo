program aleo_gas_station.aleo;

mapping gas_pool: field => u64;

// Placeholder: 1 ALEO = 1_000_000 gas units (network-estimated conversion)
const REQUIRED_GAS_UNITS_PER_WORKER: u64 = 1_000_000;

// Key = Poseidon2(employer_address, subdao_id)
inline function build_key(subdao_id: u16, employer: address) -> field {
    let sid: u128 = subdao_id as u128;
    Poseidon2::hash([employer, sid])
}

// Transition to fund ALEO gas for a given employer under a subDAO
async transition fund_gas_pool(subdao_id: u16, amount: u64) -> Future {
    let employer: address = caller;

    let key: field = build_key(subdao_id, employer);
    let current: u64 = gas_pool.get_or_use(key, 0u64);
    gas_pool.set(key, current + amount);
    return;
}

// Called before contract is created — confirms prefunding meets fixed 1 ALEO requirement
async transition check_gas_pool(subdao_id: u16, employer: address) -> Future {
    let key: field = build_key(subdao_id, employer);
    let available: u64 = gas_pool.get_or_use(key, 0u64);

    assert(available >= REQUIRED_GAS_UNITS_PER_WORKER);
    return;
}

// Deducts 1 ALEO gas cost per worker at contract activation or payroll execution
async transition deduct_gas_pool(subdao_id: u16, employer: address) -> Future {
    let key: field = build_key(subdao_id, employer);
    let current: u64 = gas_pool.get_or_use(key, 0u64);

    assert(current >= REQUIRED_GAS_UNITS_PER_WORKER);
    let new_balance: u64 = current - REQUIRED_GAS_UNITS_PER_WORKER;

    gas_pool.set(key, new_balance);
    return;
}
