program worker_profiles.aleo{

mapping worker_data: field => Worker;

struct Worker {
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    credential_hash: field,
    nonce: scalar
}

async transition register_worker(
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2]
) -> Future {
    assert(industry_code >= 1u8 && industry_code <= 15u8);
    assert(is_valid_state(state_of_residency));
    if !is_pniw {
        assert(country_of_origin == [0u8, 0u8, 0u8]);
    }

    let future: Future = finalize_register_worker(
        is_pniw,
        country_of_origin,
        industry_code,
        has_dependents,
        state_of_residency
    );
    return future;
}

async function finalize_register_worker(
    is_pniw: bool,
    country_of_origin: [u8; 3],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2]
) {
    let nonce: scalar = ChaCha::rand_scalar();

    let input: [u8; 32] = [
        is_pniw as u8,
        country_of_origin[0],
        country_of_origin[1],
        country_of_origin[2],
        industry_code,
        has_dependents as u8,
        state_of_residency[0],
        state_of_residency[1],
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
    ];

    let hash_bytes: [u8; 32] = sha3_256(input);
    let credential_hash: field = cast(hash_bytes);

    let profile: Worker = Worker {
        is_pniw,
        country_of_origin,
        industry_code,
        has_dependents,
        state_of_residency,
        credential_hash,
        nonce
    };

    worker_data.set(credential_hash, profile);
}

inline function is_valid_state(state: [u8; 2]) -> bool {
    return
        state == [65u8, 76u8] || state == [65u8, 75u8] || state == [65u8, 90u8] || state == [65u8, 82u8] ||
        state == [67u8, 65u8] || state == [67u8, 79u8] || state == [67u8, 84u8] || state == [68u8, 69u8] ||
        state == [70u8, 76u8] || state == [71u8, 65u8] || state == [72u8, 73u8] || state == [73u8, 68u8] ||
        state == [73u8, 76u8] || state == [73u8, 78u8] || state == [73u8, 65u8] || state == [75u8, 83u8] ||
        state == [75u8, 89u8] || state == [76u8, 65u8] || state == [77u8, 69u8] || state == [77u8, 68u8] ||
        state == [77u8, 65u8] || state == [77u8, 73u8] || state == [77u8, 78u8] || state == [77u8, 83u8] ||
        state == [77u8, 79u8] || state == [77u8, 84u8] || state == [78u8, 69u8] || state == [78u8, 86u8] ||
        state == [78u8, 72u8] || state == [78u8, 74u8] || state == [78u8, 77u8] || state == [78u8, 89u8] ||
        state == [78u8, 67u8] || state == [78u8, 68u8] || state == [79u8, 72u8] || state == [79u8, 75u8] ||
        state == [79u8, 82u8] || state == [80u8, 65u8] || state == [82u8, 73u8] || state == [83u8, 67u8] ||
        state == [83u8, 68u8] || state == [84u8, 78u8] || state == [84u8, 88u8] || state == [85u8, 84u8] ||
        state == [86u8, 84u8] || state == [86u8, 65u8] || state == [87u8, 65u8] || state == [87u8, 86u8] ||
        state == [87u8, 73u8] || state == [87u8, 89u8];
}}
