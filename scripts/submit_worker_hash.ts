import fetch from "node-fetch";
import fs from "fs";

// Replace with your Aleo endpoint and contract info
const ALEO_API = "https://api.explorer.provable.com/v1/testnet/transaction";
const PROGRAM_ID = "worker_profiles.aleo"; // or your actual deployed program
const TRANSITION = "add_identity";         // transition name in .leo file

// Load worker hash from file or arg
const workerData = JSON.parse(fs.readFileSync("src/output/hash.txt", "utf-8"));

// Build transaction payload
const payload = {
  program_id: PROGRAM_ID,
  transition: TRANSITION,
  inputs: [
    "Jane Worker",   // Example name
    "Wenatchee",     // City
    "WA",            // State
    "98801",         // ZIP
    workerData       // The credential_hash as field
  ]
};

async function submitTransaction() {
  const res = await fetch(ALEO_API, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload)
  });

  if (res.ok) {
    const data = await res.json();
    console.log("✅ Submitted:", data);
  } else {
    const err = await res.text();
    console.error("❌ Failed to submit:", err);
  }
}

submitTransaction();
