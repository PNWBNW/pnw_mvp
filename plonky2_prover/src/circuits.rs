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
const D: usize = 2; // Recursion depth

/// Convert a string to a Goldilocks field element (naive UTF-8 ASCII)
fn string_to_field(input: &str) -> F {
    input.bytes().fold(0u64, |acc, b| acc.wrapping_mul(256).wrapping_add(b as u64)).into()
}

/// Build the base circuit: identity + credential poseidon hash + NFT gating
fn build_base_circuit(worker: &WorkerProfile, nft_hash: F) -> (ProofWithPublicInputs<F, C, D>, CircuitData<F, C, D>) {
    let mut builder = CircuitBuilder::<F, D>::new();

    // Convert fields to Goldilocks elements
    let name = string_to_field(&worker.full_name);
    let city = string_to_field(&worker.city);
    let state = string_to_field(&worker.state);
    let zip = string_to_field(&worker.zip);
    let credential = string_to_field(&worker.credential_data);

    // Allocate as constants in the circuit
    let name_t = builder.constant(name);
    let city_t = builder.constant(city);
    let state_t = builder.constant(state);
    let zip_t = builder.constant(zip);
    let credential_t = builder.constant(credential);

    // Hash all identity fields together with Poseidon2
    let poseidon_input = vec![name_t, city_t, state_t, zip_t, credential_t];
    let poseidon_hash = poseidon_n_to_hash_no_pad(&mut builder, poseidon_input);

    // Set expected hash (replace with trusted precomputed value)
    let expected_hash = builder.constant(F::from_canonical_u64(123456789)); // Replace with real
    builder.connect(poseidon_hash, expected_hash);

    // NFT gating: credential must match NFT gate
    let nft_target = builder.constant(nft_hash);
    builder.connect(credential_t, nft_target);

    // Compile and prove
    let circuit_data = builder.build::<C>();
    let witness = PartialWitness::new();
    let proof = circuit_data.prove(witness).expect("Base proof failed");

    (proof, circuit_data)
}

/// Recursively wraps a base proof in a higher-layer verifier circuit
fn build_recursive_proof_layer(base_proof: &ProofWithPublicInputs<F, C, D>, base_circuit: &CircuitData<F, C, D>) -> Vec<u8> {
    let mut builder = CircuitBuilder::<F, D>::new();

    let verifier_data = &base_circuit.verifier_only;
    let common = &base_circuit.common;

    builder.verify_proof::<C>(base_proof.clone(), verifier_data.clone(), common.clone());

    let circuit_data = builder.build::<C>();
    let witness = PartialWitness::new();
    let wrapper_proof = circuit_data.prove(witness).expect("Recursive wrapper proof failed");

    // Output serialized proof
    bincode::serialize(&wrapper_proof).unwrap()
}

/// End-to-end wrapper: base circuit + recursive wrapper
pub fn build_recursive_proof(worker: &WorkerProfile) -> Vec<u8> {
    let nft_hash = string_to_field("CertifiedHarvestTech_2025"); // Gating credential

    let (base_proof, base_circuit) = build_base_circuit(worker, nft_hash);
    build_recursive_proof_layer(&base_proof, &base_circuit)
  }
