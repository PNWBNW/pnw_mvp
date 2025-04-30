program employer_agreement.aleo {

mapping employer_records: address => Employer;
mapping worker_profiles: address => Worker;
mapping employer_registry: [u8; 32] => bool;
mapping employer_tax_compliance: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

struct Employer {
    employer_hash: field.private,
    block_height: u32.public,
    _nonce: group.public
}

struct Worker {
    worker_data: [u8; 32].private,
    block_height: u32.public,
    _nonce: group.public
}

async transition register_employer(employer: address, employer_data: [u8; 32]) -> Employer {
    let height: u32 = block.height;
    let hash: field = hash_to_field(employer_data);

    let record: Employer = record {
        employer_hash: hash,
        block_height: height,
        _nonce: random()
    };

    employer_records.set(employer, record);
    return record;
}

async transition link_worker_to_employer(employer: address, worker: address, worker_data: [u8; 32]) -> Worker {
    let height: u32 = block.height;

    let record: Worker = record {
        worker_data: worker_data,
        block_height: height,
        _nonce: random()
    };

    worker_profiles.set(worker, record);
    return record;
}

async transition get_employer_data(employer: address) -> Employer {
    return finalize_get_employer_data(employer);
}

async function finalize_get_employer_data(employer: address) -> Employer {
    return employer_records.get(employer);
}

async transition get_worker_data(employer: address, worker: address) -> Worker {
    return finalize_get_worker_data(worker);
}

async function finalize_get_worker_data(worker: address) -> Worker {
    return worker_profiles.get(worker);
}

async transition register_employer_ans(employer_ans: [u8; 32], ans_name: [u8]) -> bool {
    return finalize_register_employer_ans(employer_ans, ans_name);
}

async function finalize_register_employer_ans(employer_ans: [u8; 32], ans_name: [u8]) -> bool {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    let registry_entry: bool = employer_registry.get_or_use(employer_ans, false);
    assert(!registry_entry);

    let reverse_entry: [u8; 32] = ans_reverse_lookup.get_or_use(encoded_ans, [
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
    ]);
    assert(reverse_entry == [
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
    ]);

    employer_registry.set(employer_ans, true);
    employer_tax_compliance.set(employer_ans, false);
    ans_registry.set(employer_ans, encoded_ans);
    ans_reverse_lookup.set(encoded_ans, employer_ans);
    return true;
}

async transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    return finalize_verify_employer_tax(employer_ans);
}

async function finalize_verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    let registered: bool = employer_registry.get_or_use(employer_ans, false);
    assert(registered);
    employer_tax_compliance.set(employer_ans, true);
    return true;
}

async transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
    return finalize_check_employer_registration(employer_ans);
}

async function finalize_check_employer_registration(employer_ans: [u8; 32]) -> bool {
    let registered: bool = employer_registry.get_or_use(employer_ans, false);
    assert(registered);
    return true;
}

async transition lookup_employer_by_ans(ans_name: [u8]) -> [u8; 32] {
    return finalize_lookup_employer_by_ans(ans_name);
}

async function finalize_lookup_employer_by_ans(ans_name: [u8]) -> [u8; 32] {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    return ans_reverse_lookup.get_or_use(encoded_ans, [
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
    ]);
}

function encode_ans(ans_name: [u8]) -> [u8; 32] {
    return hash_to_field(ans_name);
}
