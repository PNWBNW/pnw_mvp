// === stellar_handler.js ===

import { Server, Keypair, Networks, TransactionBuilder, Operation, Asset } from 'stellar-sdk';
import dotenv from 'dotenv';
import fetch from 'node-fetch';

dotenv.config();

const ALEO_API = process.env.ALEO_API; // e.g. https://api.explorer.provable.com/v1/testnet
const PROGRAM_ID = process.env.COORDINATOR_PROGRAM_ID;
const STELLAR_SECRET = process.env.STELLAR_SECRET;
const USDC_ISSUER = process.env.USDC_ISSUER;

const server = new Server('https://horizon.stellar.org');
const source = Keypair.fromSecret(STELLAR_SECRET);

async function getDispatchedPayments() {
  const res = await fetch(`${ALEO_API}/program/${PROGRAM_ID}/mapping/dispatched_payments`);
  const data = await res.json();
  return data?.keys || [];
}

async function hasBeenConfirmed(paymentHash) {
  const res = await fetch(`${ALEO_API}/program/${PROGRAM_ID}/mapping/confirmed_payments/${paymentHash}`);
  return res.status === 200;
}

async function getPayrollMetadata(paymentHash) {
  // Placeholder: Replace with actual logic if you store metadata (e.g. separate Aleo program or off-chain DB)
  return {
    stellarWallet: process.env.TEST_WORKER_WALLET,
    amountUSDC: "100.00"
  };
}

async function buildAndSendStellarUSDC(toAddress, amount) {
  const account = await server.loadAccount(source.publicKey());
  const fee = await server.fetchBaseFee();

  const tx = new TransactionBuilder(account, {
    fee,
    networkPassphrase: Networks.PUBLIC
  })
    .addOperation(Operation.payment({
      destination: toAddress,
      asset: new Asset("USDC", USDC_ISSUER),
      amount: amount
    }))
    .setTimeout(30)
    .build();

  tx.sign(source);
  return await server.submitTransaction(tx);
}

async function confirmToAleo(paymentHash) {
  const res = await fetch(`${ALEO_API}/program/${PROGRAM_ID}/transition/confirm_payment`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ inputs: [paymentHash] })
  });
  return res.status === 200;
}

async function main() {
  const dispatched = await getDispatchedPayments();

  for (const hash of dispatched) {
    const confirmed = await hasBeenConfirmed(hash);
    if (confirmed) continue;

    const { stellarWallet, amountUSDC } = await getPayrollMetadata(hash);
    const result = await buildAndSendStellarUSDC(stellarWallet, amountUSDC);

    if (result.successful) {
      await confirmToAleo(hash);
      console.log(`✅ Payment ${hash} confirmed`);
    } else {
      console.log(`❌ Payment failed for ${hash}`, result);
    }
  }
}

main().catch(console.error);
