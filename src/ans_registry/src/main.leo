program ans_registry.aleo;

mapping name_registry: [u8; 32] => address;
mapping reverse_registry: address => [u8; 32];

struct ANS {
    label: [u8; 32],
    owner: address,
    _nonce: group
}

transition register_name(label: [u8; 32], owner: address) -> ANS {
    let encoded_label: [u8; 32] = encode_label(label);

    let exists: address = name_registry.get_or_use(encoded_label, 0field.to_address());
    assert(exists == 0field.to_address());

    name_registry.set(encoded_label, owner);
    reverse_registry.set(owner, encoded_label);

    let record: ANS = record {
        label: encoded_label,
        owner,
        _nonce: random()
    };

    return record;
}

async function finalize_resolve_name(label: [u8; 32]) -> address {
    let encoded: [u8; 32] = encode_label(label);
    return name_registry.get(encoded);
}

async function finalize_reverse_lookup(owner: address) -> [u8; 32] {
    return reverse_registry.get(owner);
}

function encode_label(label: [u8; 32]) -> [u8; 32] {
    return Poseidon2::hash(label);
}
