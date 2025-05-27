program worker_profiles.aleo;

mapping worker_data: [u8; 32] => Worker;

struct Worker {
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    subdao_affiliation: address,
    credential_hash: [u8; 32],
    nonce: scalar
}

async transition register_worker(
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    subdao_affiliation: address
) -> Future {
    assert(industry_code >= 1u8 && industry_code <= 15u8);
    if !is_pniw {
        assert(country_of_origin == [0u8, 0u8, 0u8]);
    }

    let future: Future = finalize_register_worker(
        is_pniw,
        country_of_origin,
        industry_code,
        has_dependents,
        state_of_residency,
        subdao_affiliation
    );
    return future;
}

async function finalize_register_worker(
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    subdao_affiliation: address
) {
    let nonce: scalar = ChaCha::rand_scalar();
    let mut input: [u8; 41] = [
        is_pniw as u8,
        country_of_origin[0],
        country_of_origin[1],
        country_of_origin[2],
        industry_code,
        has_dependents as u8,
        state_of_residency[0],
        state_of_residency[1],
    ];

    let subdao_bytes: [u8; 32] = subdao_affiliation.to_bytes();
    input.extend(subdao_bytes);

    let credential_hash: [u8; 32] = sha3_256(input);

    let profile: Worker = Worker {
        is_pniw,
        country_of_origin,
        industry_code,
        has_dependents,
        state_of_residency,
        subdao_affiliation,
        credential_hash,
        nonce
    };

    worker_data.set(credential_hash, profile);
}
