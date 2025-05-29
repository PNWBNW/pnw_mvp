program worker_profiles.aleo{

import poseidon2.aleo;

struct WorkerIdentity {
    first_name: u128,
    last_name: u128,
    state: u128,
    city: u128,
    zip: u8
}

struct Worker {
    credential_hash: WorkerCredential,
    num_dependents: u8,
    num_minors: u8,
    is_pniw: bool,
    is_pncw: bool,
    has_dependents: bool,
    country_code: u128,
    industry_code: u16,
    _nonce: group
}

struct WorkerCredential {
    value: field
}

mapping workers: field => Worker;

async transition register_worker(
    credential_input: WorkerIdentity,
    is_pniw: bool,
    is_pncw: bool,
    has_dependents: bool,
    num_dependents: u8,
    num_minors: u8,
    country_code: u128,
    state_code: u128,
    city_code: u128,
    zip: u8,
    industry_code: u16
) {
    // Validate dependents
    let dependent_check: bool = has_dependents ? num_dependents > 0u8 : num_dependents == 0u8;
    assert(dependent_check);

    let minor_check: bool = has_dependents ? num_minors <= num_dependents : num_minors == 0u8;
    assert(minor_check);

    // Build identity and hash it
    let worker_identity: WorkerIdentity = WorkerIdentity {
        first_name: credential_input.first_name,
        last_name: credential_input.last_name,
        state: state_code,
        city: city_code,
        zip
    };

    let credential_hash_value: field = poseidon2::hash_to_field(worker_identity);
    let credential_hash: WorkerCredential = WorkerCredential { value: credential_hash_value };

    // Store the worker
    let new_worker: Worker = Worker {
        credential_hash,
        num_dependents,
        num_minors,
        is_pniw,
        is_pncw,
        has_dependents,
        country_code,
        industry_code,
        _nonce: random()
    };

    workers.set(credential_hash_value, new_worker);
}

async function get_worker(credential_hash: field) -> Worker {
    return workers.get(credential_hash);
}}
