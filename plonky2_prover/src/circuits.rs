use plonky2::field::types::Field;
use plonky2::field::goldilocks_field::GoldilocksField as F;
use plonky2::plonk::circuit_builder::CircuitBuilder;
use plonky2::plonk::config::{PoseidonGoldilocksConfig, GenericConfig};
use plonky2::plonk::circuit_data::CircuitData;
use plonky2::plonk::proof::ProofWithPublicInputs;
use plonky2::iop::witness::PartialWitness;
use plonky2::gadgets::poseidon::poseidon_n_to_hash_no_pad;

use crate::WorkerProfile;

type C = PoseidonGoldilocksConfig;
const D: usize = 2;

/// Converts a UTF-8 string to a GoldilocksField element (naive base-256 encoding)
fn string_to_field(input: &str) -> F {
    input
        .bytes()
        .fold(0u64, |acc, b| acc.wrapping_mul(256).wrapping_add(b as u64))
        .into()
}

/// Builds a base circuit that:
/// 1. Hashes the worker profile using Poseidon2
/// 2. Validates that it matches a known expected hash
/// 3. Ensures the credential matches a required NFT gate
fn build_base_circuit(
    worker: &WorkerProfile,
    nft_hash: F,
) -> (ProofWithPublicInputs<F, C, D>, CircuitData<F, C, D>) {
    let mut builder = CircuitBuilder::<F, D>::new();

    // Convert strings to Goldilocks field elements
    let name = string_to_field(&worker.full_name);
    let city = string_to_field(&worker.city);
    let state = string_to_field(&worker.state);
    let zip = string_to_field(&worker.zip);
    let credential = string_to_field(&worker.credential_data);

    // Allocate constants in the circuit
    let name_t = builder.constant(name);
    let city_t = builder.constant(city);
    let state_t = builder.constant(state);
    let zip_t = builder.constant(zip);
    let credential_t = builder.constant(credential);

    // Poseidon2 hash of identity fields
    let poseidon_input = vec![name_t, city_t, state_t, zip_t, credential_t];
    let poseidon_hash = poseidon_n_to_hash_no_pad(&mut builder, poseidon_input);

    // Replace with real trusted value (for testing, use hash_worker CLI)
    let expected_hash = builder.constant(F::from_canonical_u64(123456789));
    builder.connect(poseidon_hash, expected_hash);

    // NFT gate: credential must match approved hash
    let nft_target = builder.constant(nft_hash);
    builder.connect(credential_t, nft_target);

    // Build and prove base circuit
    let circuit_data = builder.build::<C>();
    let witness = PartialWitness::new();
    let proof = circuit_data.prove(witness).expect("Base proof failed");

    (proof, circuit_data)
}

/// Wraps the base proof in a recursive verifier circuit
fn build_recursive_proof_layer(
    base_proof: &ProofWithPublicInputs<F, C, D>,
    base_circuit: &CircuitData<F, C, D>,
) -> (Vec<u8>, CircuitData<F, C, D>) {
    let mut builder = CircuitBuilder::<F, D>::new();

    let verifier_data = &base_circuit.verifier_only;
    let common = &base_circuit.common;

    // Recursive verification of the base proof
    builder.verify_proof::<C>(
        base_proof.clone(),
        verifier_data.clone(),
        common.clone(),
    );

    let wrapper_circuit = builder.build::<C>();
    let witness = PartialWitness::new();
    let wrapper_proof = wrapper_circuit
        .prove(witness)
        .expect("Recursive wrapper proof failed");

    let proof_bytes = bincode::serialize(&wrapper_proof).unwrap();
    (proof_bytes, wrapper_circuit)
}

/// Public entry point:
/// Generates full recursive proof and returns proof bytes + circuit metadata
pub fn build_recursive_proof(worker: &WorkerProfile) -> (Vec<u8>, CircuitData<F, C, D>) {
    let nft_hash = string_to_field("CertifiedHarvestTech_2025");

    let (base_proof, base_circuit) = build_base_circuit(worker, nft_hash);
    let (proof_bytes, wrapper_circuit) =
        build_recursive_proof_layer(&base_proof, &base_circuit);

    (proof_bytes, wrapper_circuit)
}
