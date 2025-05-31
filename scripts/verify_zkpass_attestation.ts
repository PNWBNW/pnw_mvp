// scripts/verify_zkpass_attestation.ts

import { AleoNetworkClient, AleoNetworkClientConfig } from '@aleohq/sdk';

const PROGRAM_ID = 'zkpass_transgate.aleo';
const FUNCTION_NAME = 'get_attestation_info';
const EXPLORER_API = 'https://api.explorer.provable.com/v1/testnet/program';

async function verifyZKPassAttestation(proofHash: string) {
    const config: AleoNetworkClientConfig = {
        apiUrl: EXPLORER_API,
        networkId: 'testnet3'
    };

    const client = new AleoNetworkClient(config);

    try {
        const response = await client.getMappingValue<{
            who: string;
            credential_type: string;
        }>(PROGRAM_ID, 'used_proofs', proofHash);

        if (response === null) {
            console.log(`❌ Proof hash not found. ZKPass attestation is invalid.`);
            return;
        }

        console.log(`✅ ZKPass attestation found!`);
        console.log(`🔹 Attester: ${response.who}`);
        console.log(`🔹 Credential Type: ${response.credential_type}`);
    } catch (error) {
        console.error('Error verifying attestation:', error);
    }
}

// Replace with real hash for test
const testProofHash = 'YOUR_PROOF_HASH_HERE';
verifyZKPassAttestation(testProofHash);
