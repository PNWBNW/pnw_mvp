program employer_agreement.aleo {

mapping employer_records: address => [u8; 64];
mapping worker_profiles: address => [u8; 64];
mapping employer_registry: [u8; 32] => bool;
mapping employer_tax_compliance: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

transition register_employer(employer: address, employer_data: [u8; 64]) -> bool {
    employer_records.set(employer, employer_data);
    return true;
}

transition link_worker_to_employer(employer: address, worker: address, worker_data: [u8; 64]) -> bool {
    assert(employer == caller);
    worker_profiles.set(worker, worker_data);
    return true;
}

transition get_employer_data(employer: address) -> [u8; 64] {
    assert(employer == caller);
    return employer_records.get(employer);
}

transition get_worker_data(employer: address, worker: address) -> [u8; 64] {
    assert(employer == caller);
    return worker_profiles.get(worker);
}

transition register_employer_ans(employer_ans: [u8; 32], ans_name: bytes) -> bool {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);

    let registry_entry: bool = employer_registry.get(employer_ans);
    let reverse_entry: [u8; 32] = ans_reverse_lookup.get(encoded_ans);

    assert(registry_entry == false);

    let empty_entry: [u8; 32] = [0u8; 32];
    assert(reverse_entry == empty_entry);

    employer_registry.set(employer_ans, true);
    employer_tax_compliance.set(employer_ans, false);
    ans_registry.set(employer_ans, encoded_ans);
    ans_reverse_lookup.set(encoded_ans, employer_ans);

    return true;
}

transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    let registered: bool = employer_registry.get(employer_ans);
    assert(registered == true);
    employer_tax_compliance.set(employer_ans, true);
    return true;
}

transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
    let registered: bool = employer_registry.get(employer_ans);
    assert(registered == true);
    return true;
}

function lookup_employer_by_ans(ans_name: bytes) -> [u8; 32] {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    let reverse_entry: [u8; 32] = ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32u8]);
    reverse_entry
}

function encode_ans(ans_name: bytes) -> [u8; 32] {
    hash_arc721(ans_name)
}
}
