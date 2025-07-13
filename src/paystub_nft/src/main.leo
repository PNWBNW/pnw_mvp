program paystub_nft.aleo;

struct PaystubNFT {
    pnw_name: [u8; 16].private,
    worker_hash: field.private,
    employer_hash: field.private,
    amount: u64.private,
    duration_days: u16.private,
    block_height: u32.private,
    tenure_score: u16.private,
    _nonce: group.public
}

mapping paystubs: field => PaystubNFT;

async transition mint_paystub(
    pnw_name: [u8; 16],
    worker_hash: field,
    employer_hash: field,
    amount: u64,
    duration_days: u16,
    block_height: u32
) {
    assert(amount > 0u64);
    assert(duration_days > 0u16);

    let payment_hash: field = Poseidon2::hash([worker_hash, employer_hash, amount]);
    let tenure_score: u16 = duration_days;

    let paystub: PaystubNFT = PaystubNFT {
        pnw_name: pnw_name.private,
        worker_hash: worker_hash.private,
        employer_hash: employer_hash.private,
        amount: amount.private,
        duration_days: duration_days.private,
        block_height: block_height.private,
        tenure_score: tenure_score.private,
        _nonce: group.random().public
    };

    paystubs.set(payment_hash, paystub);
}

async function grant_view(
    payment_hash: field,
    requester: address,
    field_name: u8
) -> field {
    let stub: PaystubNFT = paystubs.get(payment_hash);

    match field_name {
        0u8 => return stub.worker_hash,
        1u8 => return stub.employer_hash,
        2u8 => return stub.amount,
        3u8 => return stub.duration_days,
        4u8 => return stub.block_height,
        5u8 => return stub.tenure_score,
        6u8 => return stub.pnw_name,
        _ => halt("Invalid field request");
    };
}
