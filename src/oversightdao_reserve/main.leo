import credits.aleo;

program oversightdao_reserve {
    mapping reserve_balance: [u8; 32] => u64;

    const OVERSIGHT_DAO_ANS: [u8; 32] = encode_ans(b"oversightdao.pnw.ans");

    function encode_ans(ans_name: bytes) -> [u8; 32] {
        return hash_arc721(ans_name);
    }
}
