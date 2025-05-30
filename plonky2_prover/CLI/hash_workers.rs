use std::env;
use std::fs;
use plonky2_prover::hash_utils::poseidon2_hash;

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: hash_worker <path_to_worker.json>");
        std::process::exit(1);
    }

    let path = &args[1];
    let json_data = fs::read_to_string(path)
        .expect("Failed to read the input JSON file");

    let hash = poseidon2_hash(json_data.as_bytes());
    println!("Poseidon2 field hash:\n{:#x}", hash);
}
