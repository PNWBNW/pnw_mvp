const PROGRAM_ID = "payroll_audit_log.aleo"; // Replace with your real program ID
const MAPPING_NAME = "verified_credentials"; // Replace with your real mapping
const API_BASE = "https://api.explorer.provable.com/v1/testnet";

async function checkCredentialOnChain(credentialHashHex) {
    const url = `${API_BASE}/program/${PROGRAM_ID}/mapping/${MAPPING_NAME}/${credentialHashHex}`;
    const response = await fetch(url);

    if (response.ok) {
        const data = await response.json();
        console.log("📦 On-chain credential found:", data);
        return true;
    } else if (response.status === 404) {
        console.warn("⚠️ Credential not found in audit log.");
        return false;
    } else {
        throw new Error(`🧨 API error: ${response.status}`);
    }
}

document.getElementById("verifyZPass").addEventListener("click", async () => {
    const inputHash = document.getElementById("submittedHash").value.trim();

    try {
        const isValid = await checkCredentialOnChain(inputHash);

        const statusEl = document.getElementById("verifyStatus");
        if (isValid) {
            statusEl.innerText = "✅ Credential found on-chain — ZPass Active";
            statusEl.style.color = "green";
        } else {
            statusEl.innerText = "❌ Credential not found — ZPass Denied";
            statusEl.style.color = "red";
        }
    } catch (err) {
        console.error(err);
        alert("Error verifying credential.");
    }
});
