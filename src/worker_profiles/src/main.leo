program worker_profiles.aleo {

struct WorkerIdentity {
    first_name: u128,
    last_name: u128,
    state: u128,
    city: u128,
    zip: u8
}

struct Worker {
    credential_hash: field,
    wallet_address: address,
    stellar_wallet: u256,
    block_height: u32,
    nonce: group
}

mapping credential_hashes: field => address;
mapping registered_wallets: address => field;
mapping archived_credentials: field => bool;
mapping credential_to_stellar: field => u256;

function hash_worker_identity(
    identity: WorkerIdentity,
    salt: u128
) -> field {
    poseidon2::hash_to_field(identity, salt)
}

function is_worker_registered(credential_hash: field) -> bool {
    credential_hashes.contains(credential_hash)
}

async transition register_worker(
    identity: WorkerIdentity,
    salt: u128,
    wallet_address: address,
    stellar_wallet: u256,
    block_height: u32,
    nonce: group
) {
    let credential_hash: field = hash_worker_identity(identity, salt);

    if registered_wallets.contains(wallet_address) {
        let old_hash: field = registered_wallets.get(wallet_address);
        archived_credentials[old_hash] = true;
        credential_hashes.remove(old_hash);
        credential_to_stellar.remove(old_hash);
    }

    assert(!archived_credentials.contains(credential_hash));
    assert(!credential_hashes.contains(credential_hash));

    credential_hashes[credential_hash] = wallet_address;
    registered_wallets[wallet_address] = credential_hash;
    credential_to_stellar[credential_hash] = stellar_wallet;

    let worker = Worker {
        credential_hash,
        wallet_address,
        stellar_wallet,
        block_height,
        nonce
    };

    output worker;
}

function get_worker_address(credential_hash: field) -> address {
    credential_hashes.get(credential_hash)
}

function get_stellar_wallet(credential_hash: field) -> u256 {
    credential_to_stellar.get(credential_hash)
}

function is_archived(credential_hash: field) -> bool {
    archived_credentials.contains(credential_hash)
}
}
