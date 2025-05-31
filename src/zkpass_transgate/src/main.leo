program zkpass_transgate.aleo;

import oversightdao_nft.aleo;

mapping used_proofs: field => address;
mapping proof_credential_type: field => field;

struct AttestationInfo {
    who: address,
    credential_type: field
}

async transition zkpass_attest(
    proof_hash: field,
    edition: scalar,
    credential_data: field,
    credential_type: field
) {
    assert(used_proofs.get(proof_hash).is_none());

    used_proofs.set(proof_hash, caller);
    proof_credential_type.set(proof_hash, credential_type);

    let mint_future: Future = oversightdao_nft.aleo/mint_nft(credential_data, edition);
}

function get_attestation_info(proof_hash: field) -> AttestationInfo {
    let who = used_proofs.get(proof_hash).expect("Proof not found");
    let cred_type = proof_credential_type.get(proof_hash).unwrap_or(0field);
    AttestationInfo { who, credential_type: cred_type }
}
