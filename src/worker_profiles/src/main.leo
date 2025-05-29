program worker_profiles.aleo{

import poseidon2;

// Identity structure to be hashed
struct WorkerIdentity {
    first_name: u128,
    last_name: u128,
    state: u128,
    city: u128,
    zip: u8
}

// On-chain record of worker profile
struct Worker {
    credential_hash: field,
    wallet_address: address,
    block_height: u32,
    nonce: group
}

// Mapping: credential_hash -> wallet (active identity)
mapping credential_hashes: field => address;

// Mapping: wallet -> credential_hash (1:1 active worker)
mapping registered_wallets: address => field;

// Mapping: credential_hash -> archived status
mapping archived_credentials: field => bool;

// Hash identity to field
function hash_worker_identity(
    identity: WorkerIdentity,
    salt: u128
) -> field {
    poseidon2::hash_to_field(identity, salt)
}

// Check if a credential_hash is currently active
function is_worker_registered(credential_hash: field) -> bool {
    credential_hashes.contains(credential_hash)
}

// Transition: Register new worker OR overwrite an existing one
async transition register_worker(
    identity: WorkerIdentity,
    salt: u128,
    wallet_address: address,
    block_height: u32,
    nonce: group
) {
    let credential_hash: field = hash_worker_identity(identity, salt);

    // If already registered under another hash, archive the old one
    if registered_wallets.contains(wallet_address) {
        let old_hash: field = registered_wallets.get(wallet_address);
        archived_credentials[old_hash] = true;
        credential_hashes.remove(old_hash);
    }

    // Prevent duplicate reuse of archived hashes
    assert(!archived_credentials.contains(credential_hash));
    assert(!credential_hashes.contains(credential_hash));

    // Store new mappings
    credential_hashes[credential_hash] = wallet_address;
    registered_wallets[wallet_address] = credential_hash;

    // Return updated Worker record
    let worker = Worker {
        credential_hash,
        wallet_address,
        block_height,
        nonce
    };

    output worker;
}

// View function to get wallet from credential
function get_worker_address(credential_hash: field) -> address {
    credential_hashes.get(credential_hash)
}

// Check if a hash is archived (previous version)
function is_archived(credential_hash: field) -> bool {
    archived_credentials.contains(credential_hash)
}}
