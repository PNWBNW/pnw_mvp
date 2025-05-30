use std::fs::{self, File};
use std::io::Write;
use serde::{Deserialize, Serialize};

mod circuits;
mod hash_utils;

use circuits::build_recursive_proof;
use hash_utils::poseidon2_hash;

// Represents the worker profile structure
#[derive(Serialize, Deserialize, Debug)]
struct WorkerProfile {
    full_name: String,
    city: String,
    state: String,
    zip: String,
    credential_data: String,
}

fn main() {
    // Step 1: Load input
    let input_path = "src/inputs/sample_worker.json";
    let json_data = fs::read_to_string(input_path)
        .expect("Failed to read input JSON file");

    let worker: WorkerProfile = serde_json::from_str(&json_data)
        .expect("Failed to deserialize worker input");

    println!("Loaded worker profile: {:?}", worker);

    // Step 2: Build ZK proof (stubbed)
    let proof_bytes = build_recursive_proof(&worker);

    // Step 3: Hash the proof using Poseidon2
    let proof_hash = poseidon2_hash(&proof_bytes);
    println!("Generated proof hash: {:#x}", proof_hash);

    // Step 4: Export outputs
    let output_proof_path = "src/output/proof.json";
    let output_hash_path = "src/output/hash.txt";

    fs::create_dir_all("src/output").unwrap();

    let mut proof_file = File::create(output_proof_path).unwrap();
    proof_file.write_all(&proof_bytes).unwrap();

    let mut hash_file = File::create(output_hash_path).unwrap();
    write!(hash_file, "{:#x}", proof_hash).unwrap();

    println!("Proof and hash exported.");
}
