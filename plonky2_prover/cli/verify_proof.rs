use std::env;
use std::fs;
use plonky2::field::goldilocks_field::GoldilocksField as F;
use plonky2::plonk::proof::ProofWithPublicInputs;
use plonky2::plonk::config::{PoseidonGoldilocksConfig, GenericConfig};
use plonky2::plonk::circuit_data::CircuitData;

type C = PoseidonGoldilocksConfig;
const D: usize = 2; // recursion depth

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 3 {
        eprintln!("Usage: verify_proof <proof.json> <circuit_data.bin>");
        std::process::exit(1);
    }

    let proof_path = &args[1];
    let circuit_path = &args[2];

    // Load proof
    let proof_bytes = fs::read(proof_path).expect("Failed to read proof file");
    let proof: ProofWithPublicInputs<F, C, D> = bincode::deserialize(&proof_bytes)
        .expect("Failed to deserialize proof");

    // Load circuit data
    let circuit_bytes = fs::read(circuit_path).expect("Failed to read circuit file");
    let circuit_data: CircuitData<F, C, D> = bincode::deserialize(&circuit_bytes)
        .expect("Failed to deserialize circuit");

    // Run verifier
    match circuit_data.verify(proof) {
        Ok(_) => println!("✅ Proof is valid!"),
        Err(e) => {
            eprintln!("❌ Proof is INVALID:\n{:?}", e);
            std::process::exit(1);
        }
    }
  }
