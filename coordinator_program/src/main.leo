program coordinator_program.aleo {

    async function noop_check() -> u8 {
        1u8
    }

    async transition noop_toggle() -> u8 {
        let result: u8 = await noop_check();
        result
    }

}
