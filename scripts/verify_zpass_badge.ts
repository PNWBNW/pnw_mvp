import fetch from "node-fetch";

// Constants
const API = "https://api.explorer.provable.com/v1/testnet";
const PROGRAM_ID = "payroll_audit_log.aleo";
const MAPPING = "verified_credentials"; // or credential_hashes
const credentialHash = process.argv[2]; // passed in from CLI

async function verifyZPass(hash: string) {
  const url = `${API}/program/${PROGRAM_ID}/mapping/${MAPPING}/${hash}`;
  const res = await fetch(url);

  if (res.status === 200) {
    const result = await res.json();
    console.log("✅ Credential Verified On-Chain:", result);
  } else if (res.status === 404) {
    console.log("❌ Credential not found in audit log.");
  } else {
    const err = await res.text();
    console.error("🧨 API error:", err);
  }
}

if (!credentialHash) {
  console.error("❗ Usage: ts-node verify_zpass_badge.ts <credential_hash>");
  process.exit(1);
}

verifyZPass(credentialHash);
