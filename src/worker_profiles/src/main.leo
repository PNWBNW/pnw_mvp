program worker_profiles.aleo{

mapping worker_data: field => Worker;

struct Worker {
    is_pniw: bool,
    is_pncw: bool,
    country_id: u8,
    country_of_origin_code: [u8; 4],
    industry_code: u8,
    has_dependents: bool,
    num_dependents: u8,
    num_minor_dependents: u8,
    state_of_residency: [u8; 2],
    credential_hash: field,
    nonce: scalar
}

async transition register_worker(
    is_pniw: bool,
    is_pncw: bool,
    input_country_id: u8,
    input_country_code: [u8; 4],
    industry_code: u8,
    has_dependents: bool,
    num_dependents: u8,
    num_minor_dependents: u8,
    state_of_residency: [u8; 2]
) -> Future {
    assert(is_pniw != is_pncw);
    assert(industry_code >= 1u8 && industry_code <= 15u8);
    assert(is_valid_state(state_of_residency));

    assert(has_dependents ? num_dependents > 0u8 : num_dependents == 0u8);
    assert(has_dependents ? num_minor_dependents <= num_dependents : num_minor_dependents == 0u8);

    assert(is_pniw ? is_valid_country_code(input_country_code) : input_country_code == [85u8, 83u8, 65u8, 32u8]);

    let final_country_id: u8 = is_pniw ? input_country_id : 0u8;
    let final_country_code: [u8; 4] = is_pniw ? input_country_code : [85u8, 83u8, 65u8, 32u8];

    let future: Future = finalize_register_worker(
        is_pniw,
        is_pncw,
        final_country_id,
        final_country_code,
        industry_code,
        has_dependents,
        num_dependents,
        num_minor_dependents,
        state_of_residency
    );
    return future;
}

async function finalize_register_worker(
    is_pniw: bool,
    is_pncw: bool,
    country_id: u8,
    country_of_origin_code: [u8; 4],
    industry_code: u8,
    has_dependents: bool,
    num_dependents: u8,
    num_minor_dependents: u8,
    state_of_residency: [u8; 2]
) {
    let nonce: scalar = ChaCha::rand_scalar();

    let [c0, c1, c2, c3]: [u8; 4] = country_of_origin_code;
    let [s0, s1]: [u8; 2] = state_of_residency;

    let input: [u8; 32] = [
        is_pniw as u8,
        is_pncw as u8,
        country_id,
        c0, c1, c2, c3,
        industry_code,
        has_dependents as u8,
        num_dependents,
        num_minor_dependents,
        s0, s1,
        0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8,
        0u8, 0u8
    ];

    let hash_bytes: [u8; 32] = sha3_256(input);
    let credential_hash: field = cast(hash_bytes);

    let profile: Worker = Worker {
        is_pniw,
        is_pncw,
        country_id,
        country_of_origin_code,
        industry_code,
        has_dependents,
        num_dependents,
        num_minor_dependents,
        state_of_residency,
        credential_hash,
        nonce
    };

    worker_data.set(credential_hash, profile);
}

function get_worker(credential_hash: field) -> Worker {
    let profile: Worker = worker_data.get(credential_hash);
    return profile;
}

function is_valid_state(state: [u8; 2]) -> bool {
    return check_state(0u8, state);
}

function check_state(i: u8, state: [u8; 2]) -> bool {
    let allowed_states: [[u8; 2]; 50] = [
        [65u8,76u8], [65u8,75u8], [65u8,90u8], [65u8,82u8], [67u8,65u8], [67u8,79u8], [67u8,84u8], [68u8,69u8],
        [70u8,76u8], [71u8,65u8], [72u8,73u8], [73u8,68u8], [73u8,76u8], [73u8,78u8], [73u8,65u8], [75u8,83u8],
        [75u8,89u8], [76u8,65u8], [77u8,69u8], [77u8,68u8], [77u8,65u8], [77u8,73u8], [77u8,78u8], [77u8,83u8],
        [77u8,79u8], [77u8,84u8], [78u8,69u8], [78u8,86u8], [78u8,72u8], [78u8,74u8], [78u8,77u8], [78u8,89u8],
        [78u8,67u8], [78u8,68u8], [79u8,72u8], [79u8,75u8], [79u8,82u8], [80u8,65u8], [82u8,73u8], [83u8,67u8],
        [83u8,68u8], [84u8,78u8], [84u8,88u8], [85u8,84u8], [86u8,84u8], [86u8,65u8], [87u8,65u8], [87u8,86u8],
        [87u8,73u8], [87u8,89u8]
    ];

    if i >= 50u8 {
        return false;
    }

    if state == allowed_states[i] {
        return true;
    }

    return check_state(i + 1u8, state);
}

function is_valid_country_code(code: [u8; 4]) -> bool {
    return check_country(0u8, code);
}

function check_country(i: u8, code: [u8; 4]) -> bool {
    let allowed: [[u8; 4]; 33] = [
        [85u8,83u8,65u8,32u8], [67u8,65u8,78u8,32u8], [77u8,69u8,88u8,32u8], [71u8,84u8,77u8,32u8],
        [72u8,78u8,68u8,32u8], [83u8,76u8,86u8,32u8], [78u8,73u8,67u8,32u8], [67u8,82u8,73u8,32u8],
        [80u8,65u8,78u8,32u8], [66u8,72u8,83u8,32u8], [67u8,85u8,66u8,32u8], [68u8,79u8,77u8,32u8],
        [72u8,84u8,73u8,32u8], [74u8,65u8,77u8,32u8], [84u8,84u8,79u8,32u8], [66u8,76u8,90u8,32u8],
        [66u8,82u8,66u8,32u8], [71u8,82u8,68u8,32u8], [75u8,78u8,65u8,32u8], [76u8,67u8,65u8,32u8],
        [86u8,67u8,84u8,32u8], [65u8,84u8,71u8,32u8], [65u8,82u8,71u8,32u8], [66u8,79u8,76u8,32u8],
        [66u8,82u8,65u8,32u8], [67u8,72u8,76u8,32u8], [67u8,79u8,76u8,32u8], [69u8,67u8,85u8,32u8],
        [71u8,85u8,89u8,32u8], [80u8,82u8,89u8,32u8], [80u8,69u8,82u8,32u8], [83u8,85u8,82u8,32u8],
        [85u8,82u8,89u8,32u8], [86u8,69u8,78u8,32u8]
    ];

    if i >= 33u8 {
        return false;
    }

    if code == allowed[i] {
        return true;
    }}

    return check_country(i + 1u8, code);
}
