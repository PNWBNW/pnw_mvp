// Load circuit configuration from backend
async function loadCircuitConfig() {
    const response = await fetch('/zk_config/circuit_config.json');
    if (!response.ok) {
        throw new Error("Failed to load circuit configuration.");
    }
    return await response.json();
}

// Optional hash preview element
const hashPreview = document.getElementById("hashPreview");

async function generateLiveHash(workerData) {
    const config = await loadCircuitConfig();

    // Placeholder hashing logic (replace with actual hash builder if needed)
    const hashInput = `${workerData.full_name}-${workerData.city}-${workerData.state}-${workerData.zip}-${workerData.credential_data.join(",")}`;
    const hash = await fakePoseidonHash(hashInput); // replace with Plonky2 helper if available

    hashPreview.textContent = `🔒 Hash Preview: ${hash}`;
    return hash;
}

// Simulated Poseidon2 hash generator (replace with real logic if needed)
async function fakePoseidonHash(input) {
    const encoder = new TextEncoder();
    const data = encoder.encode(input);
    const hashBuffer = await crypto.subtle.digest("SHA-256", data); // placeholder for Poseidon2
    return Array.from(new Uint8Array(hashBuffer)).map(b => b.toString(16).padStart(2, '0')).join('');
}

// Submit worker credential hash
async function submitWorkerProfile(workerData) {
    const hash = await generateLiveHash(workerData);

    const payload = {
        full_name: workerData.full_name,
        city: workerData.city,
        state: workerData.state,
        zip: workerData.zip,
        credential_hash: hash
    };

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

// ----------------- UI HANDLERS ----------------- //

const selected = [];
const buttonContainer = document.getElementById('credentialButtons');
const selectedList = document.getElementById('selectedCredentials');

// Allow users to select credentials via click
buttonContainer.addEventListener('click', async (e) => {
    const cred = e.target.dataset.cred;
    if (!cred || selected.includes(cred) || selected.length >= 5) return;

    selected.push(cred);

    const li = document.createElement('li');
    li.textContent = cred;

    const removeBtn = document.createElement('button');
    removeBtn.textContent = '❌';
    removeBtn.style.marginLeft = '10px';
    removeBtn.style.background = 'transparent';
    removeBtn.style.border = 'none';
    removeBtn.style.cursor = 'pointer';
    removeBtn.style.color = '#e74c3c';
    removeBtn.onclick = async () => {
        selected.splice(selected.indexOf(cred), 1);
        selectedList.removeChild(li);
        await updateLiveHash(); // Recalculate hash
    };

    li.appendChild(removeBtn);
    selectedList.appendChild(li);

    await updateLiveHash(); // Update hash after adding
});

document.getElementById("workerForm").addEventListener("input", updateLiveHash);

// Recalculate hash whenever form or credential list updates
async function updateLiveHash() {
    const full_name = document.getElementById("full_name").value;
    const city = document.getElementById("city").value;
    const state = document.getElementById("state").value;
    const zip = document.getElementById("zip").value;

    if (!full_name || !city || !state || !zip || selected.length === 0) {
        hashPreview.textContent = "🔒 Hash Preview: (fill out all fields)";
        return;
    }

    const workerData = {
        full_name,
        city,
        state,
        zip,
        credential_data: selected
    };

    await generateLiveHash(workerData);
}

document.getElementById("workerForm").addEventListener("submit", async (event) => {
    event.preventDefault();

    const full_name = document.getElementById("full_name").value;
    const city = document.getElementById("city").value;
    const state = document.getElementById("state").value;
    const zip = document.getElementById("zip").value;

    if (selected.length === 0) {
        alert("❗ Please select at least one credential.");
        return;
    }

    const workerData = {
        full_name,
        city,
        state,
        zip,
        credential_data: selected
    };

    await submitWorkerProfile(workerData);
});
