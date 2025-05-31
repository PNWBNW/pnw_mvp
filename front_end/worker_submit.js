// worker_submit.js

document.addEventListener('DOMContentLoaded', () => {
  const submitBtn = document.getElementById('submitWorkerProfile');

  submitBtn.addEventListener('click', async () => {
    const name = document.getElementById('workerName').value.trim();
    const pnwName = document.getElementById('pnwName').value.trim().toLowerCase();
    const state = document.getElementById('workerState').value;
    const city = document.getElementById('workerCity').value;
    const zip = document.getElementById('workerZip').value;
    const credentialHash = document.getElementById('credentialHash').value;
    const edition = document.getElementById('editionSalt').value;

    // Enforce .pnw name rule
    if (!pnwName.endsWith('.pnw')) {
      alert('Your PNW name must end in .pnw (e.g., jose123.pnw)');
      return;
    }

    if (pnwName.length < 3 || pnwName.length > 16) {
      alert('PNW name must be between 3 and 16 characters.');
      return;
    }

    // Sample call to smart contract or Aleo DApp function to register the name
    try {
      const registrationResult = await registerPNWName(pnwName);
      if (!registrationResult.success) {
        alert(`Name registration failed: ${registrationResult.error}`);
        return;
      }

      // Proceed with worker profile submission if name registered
      const workerProfile = {
        name,
        pnwName,
        state,
        city,
        zip,
        credentialHash,
        edition
      };

      // Replace with actual submit logic (e.g., Aleo DApp call)
      console.log('Submitting worker profile:', workerProfile);
      await submitWorkerProfile(workerProfile);
      alert('Worker profile successfully submitted with .pnw name.');
    } catch (err) {
      console.error('Submission error:', err);
      alert('There was an error submitting your worker profile.');
    }
  });
});

async function registerPNWName(pnwName) {
  // Placeholder logic for interacting with the PNW Name Registry smart contract
  // Must sign with wallet, send register_name() transition, and await confirmation
  return {
    success: true,
    txId: 'aleo123txn'
  };
}

async function submitWorkerProfile(profile) {
  // Placeholder for backend or Aleo smart contract submission
  // Should submit credentialHash and other profile fields on-chain
  return true;
}
