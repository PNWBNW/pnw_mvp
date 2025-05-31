# Proven National Workers (PNW-MVP)

**A privacy-focused digital payroll and compliance system built for agricultural workers, independent contractors, and small employers — powered by zero-knowledge cryptography.**

---

## What Is PNW-MVP?

The **PNW-MVP** project is a modular system built to help **farmers, workers (citizen and noncitizen), and employers** manage payroll, identity, and taxes securely — without paperwork, intermediaries, or data exposure.

This system runs on the **Aleo blockchain**, where all smart contracts are **private by default**, but still **verifiable for compliance**.

---

## Why It Matters

In industries like agriculture and seasonal labor, employers face challenges:

- Navigating tax compliance  
- Protecting worker identities  
- Minimizing payroll overhead  
- Avoiding legal and financial risk  

**PNW-MVP provides a zero-knowledge solution** that empowers all sides:

- Workers retain dignity and privacy  
- Employers stay compliant  
- Auditors gain transparent proof — without surveillance  

---

## Who It's For

- **Workers (PNCW & PNIW)**: Get paid weekly and prove credentials without revealing private info.
- **Employers**: Stay compliant with zero paperwork, and offer ethical, secure work arrangements.
- **SubDAOs / Co-ops**: Manage payroll in distributed rural groups.
- **Government agencies**: View tax proofs on-chain — without exposing identities.

---

## Core Modules

- `worker_profiles.aleo` – Stores private worker metadata and credential hashes
- `employer_profiles.aleo` – Mirrors worker logic for employers, storing attested credentials privately
- `employer_registry.aleo` – Manages employers and linked SubDAO funds
- `credential_nft.aleo` – Soulbound badge NFT system for worker certification
- `oversightdao_nft.aleo` – NFT badge system for SubDAO or audit-level employer credentials
- `pnw_name_registry.aleo` – Registers `.pnw` names required for platform participation ✅
- `pncw_payroll` & `pniw_payroll` – Weekly payroll streams by classification
- `oversightdao_reserve` – Reserve held for DAO-approved audits and compliance
- `subdao_reserve` – Local pools for community-led pay and tax contributions

---

## 🌐 PNW Name Registry (.pnw)

All participants — workers and employers — **must register a `.pnw` identity name** during onboarding.

This name:
- Is **soulbound** (non-transferable)  
- Can only be minted once per identity  
- Is required for record submissions and credential validation  

The `.pnw` system uses a **sliding fee model**:

| Name Length | Cost (Aleo credits) |
|-------------|---------------------|
| 3 letters   | 50                  |
| 4 letters   | 40                  |
| 5 letters   | 30                  |
| 6 letters   | 20                  |
| 7 letters   | 15                  |
| 8 letters   | 10                  |
| 9 letters   | 5                   |
| 10–16       | 2                   |

Names are checked for uniqueness and stored in an on-chain public mapping for discoverability. These names are integrated into the worker and employer Plonky2 flows for credential traceability without breaking privacy.

---

## How Plonky2 Proving Works

PNW-MVP integrates a **hybrid off-chain ZK proof flow** using [Plonky2](https://github.com/mir-protocol/plonky2) to enhance credential verification for both **workers and employers**.

---

### 🔧 ZPass Flow for Workers

1. Worker selects a `.pnw` name in the DApp.  
2. Frontend generates a **recursive Plonky2 proof** with identity and credential data.  
3. Credential hash is committed using `poseidon2`.  
4. Result is sent to `worker_profiles.aleo` and `.pnw` name is registered.  
5. Optionally, a DAO agent mints a **ZPass NFT** for the worker.  

---

### 🏢 ZK Attestation for Employers

1. Cooperative or DAO fills out employer details.  
2. Generates a **Plonky2 credential proof** with `.pnw` name.  
3. Credential hash is stored in `employer_profiles.aleo`.  
4. DAO mints an optional **compliance NFT** from `oversightdao_nft.aleo`.  

---

## Privacy & Security

PNW-MVP uses **zero-knowledge cryptography and recursive proving** to:

- Prove worker certification, payroll eligibility, and residency  
- Prove employer compliance and credential status  
- Obfuscate raw identity data while enabling public credential validation  
- Prevent double-registration or impersonation  

---

## Built With

- **Aleo Blockchain**: For scalable ZK contracts and private on-chain state
- **Leo Language**: Smart contract DSL optimized for zero-knowledge
- **Plonky2**: Recursive proof system for off-chain credential processing
- **Poseidon2**: Native hash function for low-cost zk commitment generation

---

## What’s Next?

- ✅ Credential loader and badge logic for ZPass workers  
- ✅ `.pnw` identity registry and wallet signing  
- ✅ Employer compliance badge via oversight DAO  
- Mobile UI for fast worker/employer onboarding  
- DAO governance for dispute mediation and compliance tracking  
- Pilot region rollout in labor-heavy agricultural zones  

---

## Contribute / Learn More

- [aleo.org](https://aleo.org)  
- [github.com/ProvableHQ](https://github.com/ProvableHQ)  
- [Plonky2](https://github.com/mir-protocol/plonky2)  

---

**PNW-MVP believes in privacy, dignity, and opportunity — for all.**
