program encoder.aleo;

import bhp256.hash;
import chacha.random;

inline function encode_name(name: [u8; 16]) -> u128 {
    let mut result: u128 = 0u128;
    let mut i: u8 = 0u8;
    while i < 16u8 {
        result = result + (name[i] as u128) * 256u128.pow(i as u32);
        i = i + 1u8;
    };
    result
};

inline function hash_name(name: [u8; 32]) -> [u8; 32] {
    return BHP256::hash(name);
};

inline function hash_industry(name: [u8; 32]) -> [u8; 32] {
    return BHP256::hash(name);
};

inline function hash_commitment_with_salt(data: [u8; 32], salt: scalar) -> field {
    return BHP256::commit_to_field(data, salt);
};

inline function random_salt() -> scalar {
    return ChaCha::rand_scalar();
};
