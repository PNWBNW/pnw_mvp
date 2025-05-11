program worker_profiles.aleo;

mapping worker_data: address => Worker;

struct Worker {
    is_pniw: bool,                      // true = PNiW, false = PNCW
    country_of_origin: [u8; 3],         // ISO country code (only if PNiW)
    industry_code: u8,                  // 1 = Agriculture, 2 = Construction, etc.
    has_dependents: bool,               // For tax filing purposes
    state_of_residency: [u8; 2],        // US state abbreviation (e.g. "CA")
    subdao_affiliation: address,        // subDAO address this worker belongs to
    _nonce: group                       // randomness for privacy
}

async transition register_worker(
    worker: address,
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    subdao_affiliation: address
) -> bool {
    if !is_pniw {
        assert(country_of_origin == [0u8, 0u8, 0u8]);
    }

    let profile: Worker = Worker {
        is_pniw,
        country_of_origin,
        industry_code,
        has_dependents,
        state_of_residency,
        subdao_affiliation,
        _nonce: random()
    };

    worker_data.set(worker, profile);
    return true;
}
