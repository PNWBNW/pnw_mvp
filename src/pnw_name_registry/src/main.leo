import poseidon2.hash;

program pnw_name_registry.aleo{

mapping name_to_address: [u128] => address;
mapping address_to_name: [address] => u128;
mapping name_to_credential_hash: [u128] => field;

function hash_name_to_field(name: u128) -> field {
    let name_bytes: [u8; 16] = name.to_bytes();
    let name_field: field = poseidon2::hash_to_field(name_bytes);
    name_field
};

async transition register_name(name: u128, owner: address) {
    let existing: address = name_to_address.get_or_use(name, 0u64.to_address());
    assert(existing == 0u64.to_address()); // prevent overwrite

    name_to_address.set(name, owner);
    address_to_name.set(owner, name);
};

async transition attach_credential(name: u128, credential_hash: field) {
    let owner: address = name_to_address.get_or_use(name, 0u64.to_address());
    assert(owner != 0u64.to_address()); // must be registered

    name_to_credential_hash.set(name, credential_hash);
};

async function resolve_name(name: u128) -> address {
    name_to_address.get_or_use(name, 0u64.to_address())
};

async function reverse_lookup(owner: address) -> u128 {
    address_to_name.get_or_use(owner, 0u128)
};

async function get_credential(name: u128) -> field {
    name_to_credential_hash.get_or_use(name, 0field)
}
}
