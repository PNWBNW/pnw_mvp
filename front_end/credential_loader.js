// ===== credential_loader.js (Fixed) =====

import CryptoJS from "crypto-js";

const ALEO_FIELD_MODULUS = BigInt("8444461749428370424248824938781546531375899335154063827935233455917409239041");

function aleoCompatibleHash(input) {
  let fieldElement;
  if (typeof input === 'string') {
    const encoder = new TextEncoder();
    const bytes = encoder.encode(input);
    let num = BigInt(0);
    for (let i = 0; i < Math.min(bytes.length, 31); i++) {
      num = (num << 8n) | BigInt(bytes[i]);
    }
    fieldElement = num % ALEO_FIELD_MODULUS;
  } else {
    fieldElement = BigInt(input) % ALEO_FIELD_MODULUS;
  }

  const generator = 7n;
  const constant = 12345678901234567890n;
  return ((fieldElement * generator) + constant) % ALEO_FIELD_MODULUS;
}

function getFieldMapping() {
  const key = "aleo2025";
  
  // Generate proper AES encryptions
  const fieldMap = {
    // Encrypt "credential_data" -> "a"
    a: CryptoJS.AES.encrypt("credential_data", key).toString(),
    // Encrypt "edition" -> "b"  
    b: CryptoJS.AES.encrypt("edition", key).toString(),
    // Encrypt "timestamp" -> "c"
    c: CryptoJS.AES.encrypt("timestamp", key).toString()
  };

  // Return reverse mapping for decryption
  return {
    credential: "credential_data", // Direct mapping since we know the structure
    edition: "edition",
    timestamp: "timestamp",
    // Obfuscated key mapping
    keyMap: {
      a: "credential_data",
      b: "edition", 
      c: "timestamp"
    }
  };
}

function validateCredentialStructure(parsed, fieldMapping) {
  const { keyMap } = fieldMapping;
  
  // Check for obfuscated keys (a, b, c) or plain keys
  const credentialKey = parsed.a !== undefined ? 'a' : 'credential_data';
  const editionKey = parsed.b !== undefined ? 'b' : 'edition';
  
  if (!parsed[credentialKey]) {
    throw new Error("Missing credential data");
  }
  
  if (!parsed[editionKey] || typeof parsed[editionKey] !== 'number' || parsed[editionKey] < 1) {
    throw new Error("Edition must be a positive number");
  }
  
  if (typeof parsed[credentialKey] !== 'string') {
    throw new Error("Credential data must be a string");
  }
}

export async function loadCredentialForAleo(fileInputId) {
  const input = document.getElementById(fileInputId);
  if (!input || !input.files || input.files.length === 0) {
    throw new Error("No credential file selected");
  }

  const file = input.files[0];

  if (file.size > 1024 * 1024) {
    throw new Error("Credential file too large (max 1MB)");
  }

  if (!file.name.toLowerCase().endsWith('.json')) {
    throw new Error("Only JSON files are supported");
  }

  let text;
  try {
    text = await file.text();
  } catch (e) {
    throw new Error("Failed to read credential file");
  }

  let parsed;
  try {
    parsed = JSON.parse(text);
  } catch (e) {
    throw new Error("Invalid JSON format in credential file");
  }

  const fieldMapping = getFieldMapping();
  validateCredentialStructure(parsed, fieldMapping);

  // Handle both obfuscated (a,b,c) and plain field names
  const credentialRaw = parsed.a || parsed.credential_data;
  const edition = parsed.b || parsed.edition;
  const timestamp = parsed.c || parsed.timestamp || Date.now();

  const credentialHash = aleoCompatibleHash(credentialRaw);

  return {
    credentialHash: credentialHash.toString(),
    edition,
    timestamp,
    raw: {
      credentialRaw,
      edition,
      timestamp
    }
  };
}

// ===== submitToAleo.js (Enhanced with error handling) =====

export async function checkAleoWallet() {
  if (!window.aleo) {
    throw new Error("Aleo wallet not found. Please install Leo Wallet or Puzzle Wallet.");
  }
  
  try {
    const accounts = await window.aleo.request({
      method: "aleo_getAccounts"
    });
    
    if (!accounts || accounts.length === 0) {
      throw new Error("No Aleo accounts found. Please connect your wallet.");
    }
    
    return accounts[0];
  } catch (error) {
    throw new Error(`Wallet connection failed: ${error.message}`);
  }
}

export async function submitToAleo(credentialHash, edition) {
  // Check wallet first
  const account = await checkAleoWallet();
  
  try {
    console.log("Submitting to Aleo:", { credentialHash, edition, account });
    
    const tx = await window.aleo.request({
      method: "aleo_executeTransition",
      params: [
        "credential_verifier.aleo", // Program name
        "verify_credential",        // Function name
        [
          `${credentialHash}field`,  // Properly formatted field
          `${edition}u32`            // Properly formatted u32
        ]
      ]
    });

    console.log("Transaction submitted:", tx);
    return tx;
    
  } catch (error) {
    console.error("Aleo submission failed:", error);
    throw new Error(`Transaction failed: ${error.message}`);
  }
}

export async function getTransactionStatus(txId) {
  try {
    const status = await window.aleo.request({
      method: "aleo_getTransaction", 
      params: [txId]
    });
    
    return status;
  } catch (error) {
    throw new Error(`Failed to get transaction status: ${error.message}`);
  }
}

// ===== Integration Example =====

export async function processCredentialFile(fileInputId) {
  try {
    // Step 1: Load and process credential
    console.log("Loading credential file...");
    const credentialData = await loadCredentialForAleo(fileInputId);
    console.log("Credential processed:", credentialData);
    
    // Step 2: Submit to Aleo
    console.log("Submitting to Aleo network...");
    const tx = await submitToAleo(
      credentialData.credentialHash, 
      credentialData.edition
    );
    
    console.log("Transaction submitted successfully:", tx);
    
    // Step 3: Optional - check status
    if (tx.transactionId) {
      setTimeout(async () => {
        try {
          const status = await getTransactionStatus(tx.transactionId);
          console.log("Transaction status:", status);
        } catch (e) {
          console.log("Status check failed:", e.message);
        }
      }, 5000);
    }
    
    return {
      success: true,
      credentialData,
      transaction: tx
    };
    
  } catch (error) {
    console.error("Process failed:", error);
    return {
      success: false,
      error: error.message
    };
  }
}

// ===== HTML Integration Example =====
/*
<!DOCTYPE html>
<html>
<head>
    <title>Aleo Credential Verifier</title>
</head>
<body>
    <div>
        <h2>Upload Credential File</h2>
        <input type="file" id="credentialFile" accept=".json">
        <button onclick="handleUpload()">Verify Credential</button>
        <div id="status"></div>
    </div>

    <script type="module">
        import { processCredentialFile } from './credential_loader.js';
        
        window.handleUpload = async function() {
            const statusDiv = document.getElementById('status');
            statusDiv.innerHTML = 'Processing...';
            
            try {
                const result = await processCredentialFile('credentialFile');
                
                if (result.success) {
                    statusDiv.innerHTML = `
                        <div style="color: green;">
                            ✅ Credential verified successfully!<br>
                            Hash: ${result.credentialData.credentialHash}<br>
                            Edition: ${result.credentialData.edition}<br>
                            TX: ${result.transaction.transactionId || 'Pending'}
                        </div>
                    `;
                } else {
                    statusDiv.innerHTML = `
                        <div style="color: red;">
                            ❌ Error: ${result.error}
                        </div>
                    `;
                }
            } catch (error) {
                statusDiv.innerHTML = `
                    <div style="color: red;">
                        ❌ Unexpected error: ${error.message}
                    </div>
                `;
            }
        };
    </script>
</body>
</html>
*/
