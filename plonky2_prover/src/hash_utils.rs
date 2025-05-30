use plonky2::field::goldilocks_field::GoldilocksField as F;
use plonky2::hash::hash_types::HashOut;
use plonky2::hash::poseidon::PoseidonHash;

/// Converts a byte array to a list of Goldilocks field elements,
/// then hashes them using Plonky2's Poseidon hash function.
/// Returns the first element of the hash output as the final field.
pub fn poseidon2_hash(input_bytes: &[u8]) -> F {
    // Chunk input into 8-byte slices and convert to field elements
    let mut inputs = vec![];

    for chunk in input_bytes.chunks(8) {
        let mut padded = [0u8; 8];
        padded[..chunk.len()].copy_from_slice(chunk);
        let value = u64::from_le_bytes(padded);
        inputs.push(F::from_canonical_u64(value));
    }

    // Hash with Poseidon (no padding, matches in-circuit logic)
    let hash_out: HashOut<F> = PoseidonHash::hash_no_pad(&inputs);

    // Return just the first field element of the result
    hash_out.elements[0]
}

/// Optional utility: hash a list of field elements directly
pub fn poseidon2_hash_fields(fields: &[F]) -> F {
    let hash_out: HashOut<F> = PoseidonHash::hash_no_pad(fields);
    hash_out.elements[0]
      }
