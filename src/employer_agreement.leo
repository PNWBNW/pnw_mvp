async transition register_employer(employer_ans: [u8; 32]) -> bool {
    assert(!employer_registry.contains(employer_ans));

    employer_registry.set(employer_ans, true);
    employer_tax_compliance.set(employer_ans, false);

    return true;
}

async transition register_employer_ans(employer_ans: [u8; 32], ans_name: bytes) -> bool {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);

    assert(employer_registry.contains(employer_ans));
    assert(!ans_reverse_lookup.contains(encoded_ans));

    ans_registry.set(employer_ans, encoded_ans);
    ans_reverse_lookup.set(encoded_ans, employer_ans);

    return true;
}

async transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    assert(employer_registry.contains(employer_ans));
    employer_tax_compliance.set(employer_ans, true);
    return true;
}

async transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
    assert(employer_registry.contains(employer_ans));
    return true;
}

function lookup_employer_by_ans(ans_name: bytes) -> [u8; 32] {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    assert(ans_reverse_lookup.contains(encoded_ans));
    return ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32]);
}
