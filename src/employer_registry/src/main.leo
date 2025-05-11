program employer_registry.aleo {

mapping employer_records: address => Employer;
mapping employer_registry: address => bool;
mapping employer_tax_compliance: address => bool;

struct Employer {
    employer_hash: field,
    nonce: scalar
}

async transition register_employer(employer: address, employer_hash: field) -> Future {
    let future: Future = finalize_register_employer(employer, employer_hash);
    return future;
}

async function finalize_register_employer(employer: address, employer_hash: field) {
    let employer_entry: Employer = Employer {
        employer_hash,
        nonce: ChaCha::rand_scalar()
    };

    employer_records.set(employer, employer_entry);
    employer_registry.set(employer, true);
    employer_tax_compliance.set(employer, false);
}

async transition verify_employer_tax(employer: address) -> Future {
    let future: Future = finalize_verify_employer_tax(employer);
    return future;
}

async function finalize_verify_employer_tax(employer: address) {
    let registered: bool = employer_registry.get_or_use(employer, false);
    assert(registered);

    employer_tax_compliance.set(employer, true);
}
}
