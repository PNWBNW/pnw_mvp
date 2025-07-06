program stellar_gas_station.aleo;

mapping usdc_pool: field => u64;

const STELLAR_GAS_FEE_PER_TX: u64 = 1_000_000; // 1 USDC in micro-units
const TAX_PERCENT: u64 = 30;

// Build a unique employer key per subDAO
inline function build_key(subdao_id: u16, employer: address) -> field {
    let sid: u128 = subdao_id as u128;
    Poseidon2::hash([employer, sid])
}

// Employers fund their Stellar USDC payroll pool
async transition fund_usdc_pool(subdao_id: u16, amount: u64) -> Future {
    let employer: address = caller;

    let key: field = build_key(subdao_id, employer);
    let current: u64 = usdc_pool.get_or_use(key, 0u64);
    usdc_pool.set(key, current + amount);
    return;
}

// Check if USDC pool has enough to cover wage + tax + Stellar gas
async transition check_usdc_pool(subdao_id: u16, employer: address, agreed_wage: u64, pay_period_days: u8) -> Future {
    let cycles: u64 = (pay_period_days as u64) / 7u64;
    let base: u64 = if cycles > 0u64 { cycles * agreed_wage } else { agreed_wage };

    // Calculate 30% tax
    let tax: u64 = (base * TAX_PERCENT) / 100u64;
    // Gas fee buffer: 1 USDC per cycle
    let gas: u64 = cycles * STELLAR_GAS_FEE_PER_TX;

    let total_needed: u64 = base + tax + gas;

    let key: field = build_key(subdao_id, employer);
    let available: u64 = usdc_pool.get_or_use(key, 0u64);

    assert(available >= total_needed);
    return;
}

// Deduct funds after payroll is executed
async transition deduct_usdc_pool(subdao_id: u16, employer: address, agreed_wage: u64, pay_period_days: u8) -> Future {
    let cycles: u64 = (pay_period_days as u64) / 7u64;
    let base: u64 = if cycles > 0u64 { cycles * agreed_wage } else { agreed_wage };

    let tax: u64 = (base * TAX_PERCENT) / 100u64;
    let gas: u64 = cycles * STELLAR_GAS_FEE_PER_TX;

    let total: u64 = base + tax + gas;

    let key: field = build_key(subdao_id, employer);
    let current: u64 = usdc_pool.get_or_use(key, 0u64);
    assert(current >= total);

    usdc_pool.set(key, current - total);
    return;
}
