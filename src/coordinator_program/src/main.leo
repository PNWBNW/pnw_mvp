program coordinator_program.aleo;

mapping dispatched_payments: field => bool;
mapping confirmed_payments: field => bool;

async transition dispatch_payment(payment_hash: field) {
    assert(!dispatched_payments.get_or_use(payment_hash, false));
    dispatched_payments.set(payment_hash, true);
}

async transition confirm_payment(payment_hash: field) {
    assert(dispatched_payments.get_or_use(payment_hash, false));
    assert(!confirmed_payments.get_or_use(payment_hash, false));
    confirmed_payments.set(payment_hash, true);
}
