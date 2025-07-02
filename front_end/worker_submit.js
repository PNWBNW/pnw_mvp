// worker_submit.js

document.addEventListener('DOMContentLoaded', () => {
  const submitBtn = document.getElementById('submitWorkerProfile');

  submitBtn.addEventListener('click', async () => {
    const name = document.getElementById('workerName').value.trim();
    const pnwName = document.getElementById('pnwName').value.trim().toLowerCase();
    const state = document.getElementById('workerState').value.trim();
    const city = document.getElementById('workerCity').value.trim();
    const zip = document.getElementById('workerZip').value.trim();
    const credentialHash = document.getElementById('credentialHash').value.trim();
    const edition = document.getElementById('editionSalt').value.trim();
    const stellarWallet = document.getElementById('stellarWallet').value.trim();

    // Enforce .pnw name rule
    if (!pnwName.endsWith('.pnw')) {
      alert('Your PNW name must end in .pnw (e.g., jose123.pnw)');
      return;
    }

    if (pnwName.length < 3 || pnwName.length > 16) {
      alert('PNW name must be between 3 and 16 characters.');
      return;
    }

    // Basic Stellar wallet format validation (G... string)
    if (!stellarWallet.startsWith('G') || stellarWallet.length !== 56) {
      alert('Invalid Stellar wallet address. Please check the format.');
      return;
    }

    try {
      const registrationResult = await registerPNWName(pnwName);
      if (!registrationResult.success) {
        alert(`Name registration failed: ${registrationResult.error}`);
        return;
      }

      const workerProfile = {
        name,
        pnwName,
        state,
        city,
        zip,
        credentialHash,
        edition,
        stellarWallet
      };

      console.log('Submitting worker profile:', workerProfile);
      await submitWorkerProfile(workerProfile);

      alert('Worker profile successfully submitted with .pnw name and Stellar wallet.');
    } catch (err) {
      console.error('Submission error:', err);
      alert('There was an error submitting your worker profile.');
    }
  });
});

async function registerPNWName(pnwName) {
  // Placeholder logic for interacting with the PNW Name Registry smart contract
  return {
    success: true,
    txId: 'aleo123txn'
  };
}

async function submitWorkerProfile(profile) {
  // Placeholder for backend or Aleo smart contract submission
  return true;
}
