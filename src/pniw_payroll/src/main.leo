program pniw_payroll.aleo;

import payroll_audit_log.aleo;
import paystub_nft.aleo;
import coordinator_program.aleo;

struct PayrollEscrow {
    employer_hash: field,
    worker_hash: field,
    amount: u64,
    duration_days: u16,
    block_height: u32,
    status: u8, // 0 = pending, 1 = confirmed
    _nonce: group
}

mapping escrows: field => PayrollEscrow;

async transition request_payroll(
    employer_hash: field,
    worker_hash: field,
    amount: u64,
    duration_days: u16
) -> Future {
    assert(amount > 0u64);

    let payment_hash: field = Poseidon2::hash([employer_hash, worker_hash, amount]);
    let escrow: PayrollEscrow = PayrollEscrow {
        employer_hash,
        worker_hash,
        amount,
        duration_days,
        block_height: block.height,
        status: 0u8,
        _nonce: group.random()
    };

    escrows.set(payment_hash, escrow);

    let future: Future = coordinator_program/dispatch_stellar_payout(payment_hash);
    return future;
}

async transition confirm_stellar_payment(payment_hash: field) -> Future {
    let escrow: PayrollEscrow = escrows.get(payment_hash);
    assert(escrow.status == 0u8);

    let updated: PayrollEscrow = PayrollEscrow {
        employer_hash: escrow.employer_hash,
        worker_hash: escrow.worker_hash,
        amount: escrow.amount,
        duration_days: escrow.duration_days,
        block_height: escrow.block_height,
        status: 1u8, // mark as confirmed
        _nonce: group.random()
    };

    escrows.set(payment_hash, updated);

    let future: Future = release_paystub(payment_hash);
    return future;
}

async function release_paystub(payment_hash: field) {
    let escrow: PayrollEscrow = escrows.get(payment_hash);
    assert(escrow.status == 1u8); // only release NFT after Stellar payout

    async paystub_nft/mint_paystub(
        escrow.worker_hash,
        escrow.employer_hash,
        escrow.amount,
        escrow.duration_days,
        escrow.block_height
    );

    async payroll_audit_log/record_payment_hash(payment_hash, block.height);
}
