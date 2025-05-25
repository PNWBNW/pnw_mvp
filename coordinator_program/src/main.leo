program coordinator_program.aleo{

async transition route_action(action: [u8; 16], payload: [u8; 32]) -> [u8; 32] {
    let encoded = encode_name(action);
    let fingerprint = hash_name(encoded);
    return fingerprint;
}
}
