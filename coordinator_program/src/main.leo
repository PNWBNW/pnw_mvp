program coordinator_program.aleo {

async transition noop_toggle() -> Future {
    let result: Future = noop_finish();
    return result;
}

async function noop_finish() -> u8 {
    1u8
}

}
