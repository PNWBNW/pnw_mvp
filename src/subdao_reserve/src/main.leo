program subdao_reserve.aleo {

mapping reserve_balance: address => u64;
mapping tax_obligations: address => u64;

const TAX_RATE: u64 = 10u64;

async transition deposit(subdao_address: address, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_deposit(subdao_address, amount);
    return future;
}

async function finalize_deposit(subdao_address: address, amount: u64) {
    let current_balance: u64 = reserve_balance.get_or_use(subdao_address, 0u64);
    let new_balance: u64 = current_balance + amount;

    reserve_balance.set(subdao_address, new_balance);
}

async transition process_taxes(subdao_address: address) -> Future {
    let future: Future = finalize_process_taxes(subdao_address);
    return future;
}

async function finalize_process_taxes(subdao_address: address) {
    let current_balance: u64 = reserve_balance.get_or_use(subdao_address, 0u64);
    assert(current_balance > 0u64);

    let tax_amount: u64 = current_balance * TAX_RATE / 100u64;
    let net_amount: u64 = current_balance - tax_amount;

    reserve_balance.set(subdao_address, net_amount);

    let current_tax_obligation: u64 = tax_obligations.get_or_use(subdao_address, 0u64);
    let new_tax_obligation: u64 = current_tax_obligation + tax_amount;

    tax_obligations.set(subdao_address, new_tax_obligation);
}

async transition withdraw(subdao_address: address, amount: u64) -> Future {
    assert(amount > 0u64);

    let future: Future = finalize_withdraw(subdao_address, amount);
    return future;
}

async function finalize_withdraw(subdao_address: address, amount: u64) {
    let current_balance: u64 = reserve_balance.get_or_use(subdao_address, 0u64);
    assert(current_balance >= amount);

    let new_balance: u64 = current_balance - amount;
    reserve_balance.set(subdao_address, new_balance);
}
}
