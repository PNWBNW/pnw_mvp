program coordinator_program.aleo {

async function echo_payload(payload: [u8; 32]) -> [u8; 32] {
    return payload;
}

async transition route_action(action: [u8; 16], payload: [u8; 32]) -> [u8; 32]; Future {
    let result: Future = echo_payload(payload);
    return await result;
}

}}
