program worker_profiles.aleo {

mapping worker_data: address => Worker;

struct Worker {
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    subdao_affiliation: address,
    nonce: scalar
}

async transition register_worker(
    worker: address,
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
        worker,
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
    worker: address,
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    subdao_affiliation: address
) {
    let profile: Worker = Worker {
        is_pniw,
        country_of_origin,
        industry_code,
        has_dependents,
        state_of_residency,
        subdao_affiliation,
        nonce: ChaCha::rand_scalar()
    };

    worker_data.set(worker, profile);
}
}
