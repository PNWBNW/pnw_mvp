program worker_profiles.aleo;

mapping zpass_registry: address => field;
mapping ans_registry: address => [u8; 32];

struct WorkerProfile {
    zpass_hash: field,
    ans_hash: [u8; 32]
}

async transition register_worker_profile(worker: address, zpass_id: [u8], ans_name: [u8]) -> WorkerProfile {
    let zpass_hash: field = hash_arc721(zpass_id);
    let ans_hash: [u8; 32] = hash_arc721(ans_name);

    zpass_registry.set(worker, zpass_hash);
    ans_registry.set(worker, ans_hash);

    let profile: WorkerProfile = WorkerProfile {
        zpass_hash,
        ans_hash
    };

    return profile;
}

async transition get_worker_profile(worker: address) -> WorkerProfile {
    return finalize_get_worker_profile(worker);
}

async function finalize_get_worker_profile(worker: address) -> WorkerProfile {
    let zpass_hash: field = zpass_registry.get(worker);
    let ans_hash: [u8; 32] = ans_registry.get(worker);

    let profile: WorkerProfile = WorkerProfile {
        zpass_hash,
        ans_hash
    };

    return profile;
}

function hash_arc721(input: [u8]) -> [u8; 32] {
    return hash_to_field(input).to_bytes();
}
