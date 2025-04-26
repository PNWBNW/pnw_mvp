program employer_agreement.aleo {

import context.leo;
import mapping.leo;
import assert.leo;
import crypto.leo;
import bytes.leo;
import field.leo;
import math.leo;
import option.leo;
import result.leo;
import env.leo;
import record.leo;
import worker_profiles.leo;
import subdao_reserve.leo;

mapping employer_records: address => [u8; 64];
mapping worker_profiles: address => [u8; 64];
mapping employer_registry: [u8; 32] => bool;
mapping employer_tax_compliance: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

transition register_employer(employer: address, employer_data: [u8; 64]) -> bool {
    employer_records[employer] = employer_data;
    return true;
}

transition link_worker_to_employer(employer: address, worker: address, worker_data: [u8; 64]) -> bool {
    assert employer == caller;
    worker_profiles[worker] = worker_data;
    return true;
}

transition get_employer_data(employer: address) -> [u8; 64] {
    assert employer == caller;
    return employer_records[employer];
}

transition get_worker_data(employer: address, worker: address) -> [u8; 64] {
    assert employer == caller;
    return worker_profiles[worker];
}

transition register_employer_ans(employer_ans: [u8; 32], ans_name: bytes) -> bool {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    assert !employer_registry.contains(employer_ans);
    assert !ans_reverse_lookup.contains(encoded_ans);

    employer_registry.set(employer_ans, true);
    employer_tax_compliance.set(employer_ans, false);
    ans_registry.set(employer_ans, encoded_ans);
    ans_reverse_lookup.set(encoded_ans, employer_ans);

    return true;
}

transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
    assert employer_registry.contains(employer_ans);
    employer_tax_compliance.set(employer_ans, true);
    return true;
}

transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
    assert employer_registry.contains(employer_ans);
    return true;
}

function lookup_employer_by_ans(ans_name: bytes) -> [u8; 32] {
    let encoded_ans: [u8; 32] = encode_ans(ans_name);
    assert ans_reverse_lookup.contains(encoded_ans);
    return ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32]);
}

}

