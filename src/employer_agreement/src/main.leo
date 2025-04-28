program employer_agreement.aleo;

mapping employer_records: address => [u8; 32];
mapping worker_profiles: address => [u8; 32];
mapping employer_registry: [u8; 32] => bool;
mapping employer_tax_compliance: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

async transition register_employer(employer: address, employer_data: [u8; 32]) -> bool {
    employer_records.set(employer, employer_data);
    true
}

async transition link_worker_to_employer(employer: address, worker: address, worker_data: [u8; 32]) -> bool {
    worker_profiles.set(worker, worker_data);
    true
}

async transition get_employer_data(employer: address) -> [u8; 32] {
    employer_records.get(employer)
}

async transition get_worker_data(employer: address, worker: address) -> [u8; 32] {
    worker_profiles.get(worker)
}

async transition register_employer_ans(employer_ans: [u8; 32], ans_name: [u8]) -> bool {
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

    true
}

async transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    let registered: bool = employer_registry.get_or_use(employer_ans, false);
    assert(registered);

    employer_tax_compliance.set(employer_ans, true);
    true
}

async transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
    let registered: bool = employer_registry.get_or_use(employer_ans, false);
    assert(registered);
    true
}

async transition lookup_employer_by_ans(ans_name: [u8]) -> [u8; 32] {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    ans_reverse_lookup.get_or_use(encoded_ans, [
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8,
        0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8, 0u8
    ])
}

function encode_ans(ans_name: [u8]) -> [u8; 32] {
    hash_to_field(ans_name)
}
