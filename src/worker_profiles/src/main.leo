program worker_profiles.aleo{

mapping worker_data: field => Worker;

struct Worker {
    is_pniw: bool,
    country_id: u8,
    country_of_origin_code: [u8; 4],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2],
    credential_hash: field,
    nonce: scalar
}

async transition register_worker(
    is_pniw: bool,
    country_id: u8,
    country_of_origin_code: [u8; 4],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2]
) -> Future {
    assert(industry_code >= 1u8 && industry_code <= 15u8);
    assert(is_valid_state(state_of_residency));
    assert(is_valid_country_code(country_of_origin_code));

    let future: Future = finalize_register_worker(
        is_pniw,
        country_id,
        country_of_origin_code,
        industry_code,
        has_dependents,
        state_of_residency
    );
    return future;
}

async function finalize_register_worker(
    is_pniw: bool,
    country_id: u8,
    country_of_origin_code: [u8; 4],
    industry_code: u8,
    has_dependents: bool,
    state_of_residency: [u8; 2]
) {
    let nonce: scalar = ChaCha::rand_scalar();

    let input: [u8; 32] = [
        is_pniw as u8,
        country_id,
        country_of_origin_code[0],
        country_of_origin_code[1],
        country_of_origin_code[2],
        country_of_origin_code[3],
        industry_code,
        has_dependents as u8,
        state_of_residency[0],
        state_of_residency[1],
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8
    ];

    let hash_bytes: [u8; 32] = sha3_256(input);
    let credential_hash: field = cast(hash_bytes);

    let profile: Worker = Worker {
        is_pniw,
        country_id,
        country_of_origin_code,
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
        state == [65,76] || state == [65,75] || state == [65,90] || state == [65,82] ||
        state == [67,65] || state == [67,79] || state == [67,84] || state == [68,69] ||
        state == [70,76] || state == [71,65] || state == [72,73] || state == [73,68] ||
        state == [73,76] || state == [73,78] || state == [73,65] || state == [75,83] ||
        state == [75,89] || state == [76,65] || state == [77,69] || state == [77,68] ||
        state == [77,65] || state == [77,73] || state == [77,78] || state == [77,83] ||
        state == [77,79] || state == [77,84] || state == [78,69] || state == [78,86] ||
        state == [78,72] || state == [78,74] || state == [78,77] || state == [78,89] ||
        state == [78,67] || state == [78,68] || state == [79,72] || state == [79,75] ||
        state == [79,82] || state == [80,65] || state == [82,73] || state == [83,67] ||
        state == [83,68] || state == [84,78] || state == [84,88] || state == [85,84] ||
        state == [86,84] || state == [86,65] || state == [87,65] || state == [87,86] ||
        state == [87,73] || state == [87,89];
}

inline function is_valid_country_code(code: [u8; 4]) -> bool {
    return
        code == [85,83,65,32] || code == [67,65,78,32] || code == [77,69,88,32] || code == [71,84,77,32] ||
        code == [72,78,68,32] || code == [83,76,86,32] || code == [78,73,67,32] || code == [67,82,73,32] ||
        code == [80,65,78,32] || code == [66,72,83,32] || code == [67,85,66,32] || code == [68,79,77,32] ||
        code == [72,84,73,32] || code == [74,65,77,32] || code == [84,84,79,32] || code == [66,76,90,32] ||
        code == [66,82,66,32] || code == [71,82,68,32] || code == [75,78,65,32] || code == [76,67,65,32] ||
        code == [86,67,84,32] || code == [65,84,71,32] || code == [65,82,71,32] || code == [66,79,76,32] ||
        code == [66,82,65,32] || code == [67,72,76,32] || code == [67,79,76,32] || code == [69,67,85,32] ||
        code == [71,85,89,32] || code == [80,82,89,32] || code == [80,69,82,32] || code == [83,85,82,32] ||
        code == [85,82,89,32] || code == [86,69,78,32];
}}
