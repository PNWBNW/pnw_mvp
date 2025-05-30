// Load circuit configuration from backend
async function loadCircuitConfig() {
    const response = await fetch('/zk_config/circuit_config.json');
    if (!response.ok) {
        throw new Error("Failed to load circuit configuration.");
    }
    return await response.json();
}

// Submit worker credential hash to Aleo backend or relayer
async function submitWorkerProfile(workerData) {
    const config = await loadCircuitConfig();

    console.log("🔍 Loaded circuit config:", config);

    // Basic validation (e.g., check credential match or precomputed hash)
    if (workerData.credential_data !== config.nft_gate_credential) {
        alert("🚫 This worker is missing the required NFT credential.");
        return;
    }

    // Optional: Show precomputed hash for frontend display
    console.log("🧾 Expected Poseidon2 hash:", config.expected_poseidon_hash_hex);

    // Prepare submission payload
    const payload = {
        full_name: workerData.full_name,
        city: workerData.city,
        state: workerData.state,
        zip: workerData.zip,
        credential_hash: config.expected_poseidon_hash_hex // precomputed off-chain
    };

    // Example POST request to a backend API or Aleo gateway
    const response = await fetch('/api/submit_worker', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
    });

    if (response.ok) {
        alert("✅ Worker profile submitted successfully.");
    } else {
        alert("❌ Submission failed.");
    }
}

// Hook to your HTML form
document.getElementById("workerForm").addEventListener("submit", async (event) => {
    event.preventDefault();

    const workerData = {
        full_name: document.getElementById("full_name").value,
        city: document.getElementById("city").value,
        state: document.getElementById("state").value,
        zip: document.getElementById("zip").value,
        credential_data: document.getElementById("credential_data").value
    };

    await submitWorkerProfile(workerData);
});
