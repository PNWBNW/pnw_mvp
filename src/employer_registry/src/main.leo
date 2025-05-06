program employer_registry.aleo {

mapping employer_records: address => Employer;
mapping employer_registry: [u8; 32] => bool;
mapping employer_tax_compliance: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

struct Employer {
    employer_hash: field,
    nonce: group
}

async transition register_employer(employer: address, employer_hash: field) -> Employer {
    let employer_entry: Employer = Employer {
        employer_hash,
        nonce: random()
    };
    employer_records.set(employer, employer_entry);
    return employer_entry;
}

async transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    let future: Future = employer_registry.aleo/finalize_verify_employer_tax(employer_ans);
    let result = await future;
    return result;
}

async function finalize_verify_employer_tax(employer_ans: [u8; 32]) {
    let registered: bool = employer_registry.get_or_use(employer_ans, false);
    assert(registered);
    employer_tax_compliance.set(employer_ans, true);
}

async transition register_employer_ans(employer_ans: [u8; 32], ans_name: [u8]) -> bool {
    let future: Future = employer_registry.aleo/finalize_register_employer_ans(employer_ans, ans_name);
    let result = await future;
    return result;
}

async function finalize_register_employer_ans(employer_ans: [u8; 32], ans_name: [u8]) {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);

    let registry_entry: bool = employer_registry.get_or_use(employer_ans, false);
    assert(!registry_entry);

    let reverse_entry: [u8; 32] = ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32]);
    assert(reverse_entry == [0u8; 32]);

    employer_registry.set(employer_ans, true);
    employer_tax_compliance.set(employer_ans, false);
    ans_registry.set(employer_ans, encoded_ans);
    ans_reverse_lookup.set(encoded_ans, employer_ans);
}

async transition lookup_employer_by_ans(ans_name: [u8]) -> [u8; 32] {
    return finalize_lookup_employer_by_ans(ans_name);
}

async function finalize_lookup_employer_by_ans(ans_name: [u8]) -> [u8; 32] {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    return ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32]);
}

function encode_ans(ans_name: [u8]) -> [u8; 32] {
    return hash_to_field(ans_name);
}
