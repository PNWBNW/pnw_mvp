program worker_profiles.aleo;

import zpass_verifier.aleo;
import ans_registry.aleo;

mapping worker_data: address => Worker;

struct Worker {
    zpass_verified: bool,
    ans_name: [u8; 32],
    _nonce: group
}

async transition register_worker(worker: address, zpass_id: field, ans_hash: [u8; 32]) -> bool {
    let future_zpass: Future = zpass_verifier.aleo/verify_zpass(zpass_id);
    let future_ans: Future = ans_registry.aleo/verify_ans(ans_hash);

    let verified: bool = await finalize_verification(future_zpass, future_ans, ans_hash);

    let profile: Worker = Worker {
        zpass_verified: verified,
        ans_name: ans_hash,
        _nonce: random()
    };

    worker_data.set(worker, profile);
    return true;
}

async function finalize_verification(fz: Future, fa: Future, ans_hash: [u8; 32]) -> bool {
    let zpass_ok: bool = await fz;
    let ans_ok: bool = await fa;

    assert(zpass_ok);
    assert(ans_ok);

    return true;
}
