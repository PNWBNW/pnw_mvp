import poseidon2.hash;
import credits.aleo;

program pnw_name_registry.aleo {

mapping name_to_address: [u128] => address;
mapping address_to_name: [address] => u128;
mapping name_to_credential_hash: [u128] => field;

// ---------------------------
// UTILITY FUNCTIONS
// ---------------------------

function hash_name_to_field(name: u128) -> field {
    let name_bytes: [u8; 16] = name.to_bytes();
    poseidon2::hash_to_field(name_bytes)
};

function calculate_fee(name: u128) -> u64 {
    let length: u8 = name.to_bytes()[15]; // Last byte encodes length
    assert(length >= 3u8);
    assert(length <= 16u8);

    if length == 3u8 {
        50u64
    } else if length == 4u8 {
        40u64
    } else if length == 5u8 {
        30u64
    } else if length == 6u8 {
        20u64
    } else if length == 7u8 {
        15u64
    } else if length == 8u8 {
        10u64
    } else if length == 9u8 {
        5u64
    } else {
        2u64
    }
};

function is_taken(name: u128) -> bool {
    let existing: address = name_to_address.get_or_use(name, 0u64.to_address());
    existing != 0u64.to_address()
};

// ---------------------------
// MAIN TRANSITIONS
// ---------------------------

async transition register_name(name: u128, owner: address, fee_record: credits.aleo/credits) -> credits.aleo/credits {
    assert(!is_taken(name));

    let length: u8 = name.to_bytes()[15];
    assert(length >= 3u8);
    assert(length <= 16u8);

    let fee: u64 = calculate_fee(name);
    assert(fee_record.amount >= fee);

    let remaining_amount: u64 = fee_record.amount - fee;
    let change_record: credits.aleo/credits = record {
        owner: fee_record.owner,
        amount: remaining_amount,
        _nonce: fee_record._nonce
    };

    name_to_address.set(name, owner);
    address_to_name.set(owner, name);

    change_record
};

async transition attach_credential(name: u128, credential_hash: field) {
    let owner: address = name_to_address.get_or_use(name, 0u64.to_address());
    assert(owner != 0u64.to_address());

    name_to_credential_hash.set(name, credential_hash);
};

// ---------------------------
// GETTERS (READ ONLY)
// ---------------------------

async function resolve_name(name: u128) -> address {
    name_to_address.get_or_use(name, 0u64.to_address())
};

async function reverse_lookup(owner: address) -> u128 {
    address_to_name.get_or_use(owner, 0u128)
};

async function get_credential(name: u128) -> field {
    name_to_credential_hash.get_or_use(name, 0field)
};
}
