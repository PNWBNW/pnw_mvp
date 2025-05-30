use std::fs::{self, File};
use std::io::Write;
use serde::{Deserialize, Serialize};

mod circuits;
mod hash_utils;

use circuits::build_recursive_proof;
use hash_utils::poseidon2_hash;

use plonky2::plonk::circuit_data::CircuitData;
use plonky2::plonk::config::PoseidonGoldilocksConfig;
use plonky2::field::goldilocks_field::GoldilocksField as F;

#[derive(Serialize, Deserialize, Debug)]
pub struct WorkerProfile {
    pub full_name: String,
    pub city: String,
    pub state: String,
    pub zip: String,
    pub credential_data: String,
}

fn main() {
    // Step 1: Load JSON input
    let input_path = "src/inputs/sample_worker.json";
    let json_data = fs::read_to_string(input_path)
        .expect("Failed to read input JSON file");

    let worker: WorkerProfile = serde_json::from_str(&json_data)
        .expect("Failed to deserialize JSON");

    println!("👤 Loaded worker profile: {:?}", worker);

    // Step 2: Build proof + get serialized result
    let (proof_bytes, circuit_data): (Vec<u8>, CircuitData<F, PoseidonGoldilocksConfig, 2>) =
        build_recursive_proof(&worker);

    // Step 3: Compute Poseidon2 hash of the proof
    let proof_hash = poseidon2_hash(&proof_bytes);
    println!("🔐 Generated proof hash: {:#x}", proof_hash);

    // Step 4: Export proof, hash, and circuit metadata
    fs::create_dir_all("src/output").unwrap();

    let mut proof_file = File::create("src/output/proof.json").unwrap();
    proof_file.write_all(&proof_bytes).unwrap();

    let mut hash_file = File::create("src/output/hash.txt").unwrap();
    write!(hash_file, "{:#x}", proof_hash).unwrap();

    let circuit_bin = bincode::serialize(&circuit_data).expect("Circuit serialization failed");
    let mut circuit_file = File::create("src/output/circuit_data.bin").unwrap();
    circuit_file.write_all(&circuit_bin).unwrap();

    println!("📁 Exported to: src/output/proof.json, hash.txt, and circuit_data.bin");
}
