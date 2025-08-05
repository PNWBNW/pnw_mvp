// === stellar_tx_log.js ===

import fs from 'fs';
import path from 'path';

const LOG_FILE = path.resolve('stellar_sdk/stellar_audit_log.json');

// Load existing log or initialize
function loadLog() {
  try {
    return JSON.parse(fs.readFileSync(LOG_FILE, 'utf-8'));
  } catch {
    return [];
  }
}

function maskWalletAddress(address) {
  if (!address || address.length < 6) return '*****';
  return `****${address.slice(-6)}`;
}

function logTransaction({
  paymentHash,
  txHash,
  amountUSDC,
  destinationWallet
}) {
  const log = loadLog();

  const entry = {
    payment_hash: paymentHash,             // Aleo hash
    tx_hash: txHash,                       // Stellar hash
    timestamp: new Date().toISOString(),   // UTC
    amount_usdc: amountUSDC,
    destination_wallet: maskWalletAddress(destinationWallet)
  };

  log.push(entry);
  fs.writeFileSync(LOG_FILE, JSON.stringify(log, null, 2));
  console.log(`🧾 Logged payout: ${paymentHash} → ${entry.destination_wallet}`);
}

export { logTransaction };
