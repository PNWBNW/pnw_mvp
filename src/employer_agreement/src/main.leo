program employer_agreement.aleo{

import ans_registry.aleo;

mapping employer_records: address => Employer;
mapping employer_registry: [u8; 32] => bool;

struct Employer {
    employer_hash: field,
    _nonce: group
}

async transition register_employer(employer: address, employer_hash: field) -> bool {
    let record: Employer = Employer {
        employer_hash,
        _nonce: random()
    };

    employer_records.set(employer, record);
    return true;
}

async transition register_employer_ans(employer: address, ans_hash: [u8; 32]) -> bool {
    let is_registered: bool = employer_registry.get_or_use(ans_hash, false);
    assert(!is_registered);

    let record: Employer = employer_records.get(employer);
    assert(record.employer_hash != 0field);

    let future: Future = ans_registry.aleo/register_ans(ans_hash);
    let verified: bool = await future;

    assert(verified);

    employer_registry.set(ans_hash, true);
    return true;
}
}
