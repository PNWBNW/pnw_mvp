use plonky2::field::types::Field;
use plonky2::field::goldilocks_field::GoldilocksField as F;
use plonky2::plonk::circuit_builder::CircuitBuilder;
use plonky2::plonk::config::{PoseidonGoldilocksConfig, GenericConfig};
use plonky2::plonk::circuit_data::CircuitData;
use plonky2::plonk::proof::ProofWithPublicInputs;
use plonky2::iop::witness::PartialWitness;
use plonky2::gadgets::poseidon::poseidon_n_to_hash_no_pad;
use types::WorkerProfile;
use crate::WorkerProfile;

mod types;

type C = PoseidonGoldilocksConfig;
const D: usize = 2;

fn string_to_field(input: &str) -> F {
    input
        .bytes()
        .fold(0u64, |acc, b| acc.wrapping_mul(256).wrapping_add(b as u64))
        .into()
}

fn poseidon2_hash_stacked_credentials(builder: &mut CircuitBuilder<F, D>, credentials: &[String]) -> F {
    assert!(credentials.len() <= 5, "Max of 5 credentials allowed");

    let mut fields = vec![F::ZERO; 5];
    for (i, cred) in credentials.iter().enumerate().take(5) {
        fields[i] = string_to_field(cred);
    }

    let field_targets: Vec<_> = fields.iter().map(|f| builder.constant(*f)).collect();
    builder.constant(poseidon_n_to_hash_no_pad(builder, field_targets))
}

fn build_base_circuit(
    worker: &WorkerProfile,
    nft_hash: F,
) -> (ProofWithPublicInputs<F, C, D>, CircuitData<F, C, D>) {
    let mut builder = CircuitBuilder::<F, D>::new();

    // Convert strings to field elements
    let name = string_to_field(&worker.full_name);
    let city = string_to_field(&worker.city);
    let state = string_to_field(&worker.state);
    let zip = string_to_field(&worker.zip);
    let pnw_name = string_to_field(&worker.pnw_name); // ✅ NEW FIELD

    let name_t = builder.constant(name);
    let city_t = builder.constant(city);
    let state_t = builder.constant(state);
    let zip_t = builder.constant(zip);
    let pnw_t = builder.constant(pnw_name); // ✅

    let credential_hash = poseidon2_hash_stacked_credentials(&mut builder, &worker.credential_data);
    let credential_t = builder.constant(credential_hash);

    // Add .pnw domain into poseidon commitment
    let poseidon_input = vec![name_t, city_t, state_t, zip_t, pnw_t, credential_t];
    let poseidon_hash = poseidon_n_to_hash_no_pad(&mut builder, poseidon_input);

    let expected_hash = builder.constant(F::from_canonical_u64(123456789)); // Placeholder
    builder.connect(poseidon_hash, expected_hash);

    let nft_target = builder.constant(nft_hash);
    builder.connect(credential_t, nft_target);

    let circuit_data = builder.build::<C>();
    let witness = PartialWitness::new();
    let proof = circuit_data.prove(witness).expect("Base proof failed");

    (proof, circuit_data)
}

fn build_recursive_proof_layer(
    base_proof: &ProofWithPublicInputs<F, C, D>,
    base_circuit: &CircuitData<F, C, D>,
) -> (Vec<u8>, CircuitData<F, C, D>) {
    let mut builder = CircuitBuilder::<F, D>::new();
    builder.verify_proof::<C>(
        base_proof.clone(),
        base_circuit.verifier_only.clone(),
        base_circuit.common.clone(),
    );

    let wrapper = builder.build::<C>();
    let witness = PartialWitness::new();
    let proof = wrapper.prove(witness).expect("Recursive wrapper failed");

    let proof_bytes = bincode::serialize(&proof).unwrap();
    (proof_bytes, wrapper)
}

pub fn build_recursive_proof(worker: &WorkerProfile) -> (Vec<u8>, CircuitData<F, C, D>) {
    let nft_hash = string_to_field("CertifiedHarvestTech_2025");
    let (base_proof, base_circuit) = build_base_circuit(worker, nft_hash);
    let (proof_bytes, wrapper_circuit) = build_recursive_proof_layer(&base_proof, &base_circuit);

    (proof_bytes, wrapper_circuit)
                                                         }
