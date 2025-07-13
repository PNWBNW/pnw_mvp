# 🌲 Proven National Workers (PNW-MVP)

**A zero-knowledge payroll infrastructure for real-world USDC payouts and fully private auditing. Built on Aleo + Stellar.**

---

## 🔍 Overview

**PNW-MVP** is a hybrid on-chain/off-chain system designed for:
- 💼 Employers
- 🧑🏽‍🌾 Migrant (PNiW) and citizen workers (PNcW)
- 🏛 SubDAOs & compliance DAOs
- 🪙 Gas-optimized cross-chain payroll

It combines:
- Aleo for private state, ZK proof, and NFT paystubs
- Stellar for real-world USDC disbursements
- Internal escrow logic and wallet binding to enable seamless coordination

---

## 🧱 Architecture Summary

**ZK-Attested Identity & Payroll Records (Aleo)**  
→  
**.wasm Outputs Trigger Stellar Payouts via SDK + Horizon API**  
→  
**Escrow confirms before releasing private NFT paystub**  
→  
**Stellar tx hash and audit hash stored privately**  

All operations maintain privacy while ensuring full accountability.

---

## ✅ Phase Roadmap

### Phase 1 – Worker Credential System  
- Bind Stellar wallet to Aleo wallet  
- ZK-prove credential hash using Poseidon2  
- Store worker identity & country-of-origin/residency in struct  
- Commit PNiW/PNcW classification  

### Phase 2 – Employer Agreement Rebuild  
- Require SubDAO and .pnw domain  
- Ensure employer prefunds both ALEO and USDC gas  
- Use duration × worker count to determine gas requirement  
- Register contract start block height  

### Phase 3 – Gas Station Contracts  
- `aleo_gas_station.aleo`: validates ALEO prefunding  
- `stellar_gas_station.aleo`: validates Stellar USDC + tax reserve  
  - Placeholder: 1 USDC + 30% tax buffer per worker per cycle  

### Phase 4 – Payroll System  
- `pniw_payroll.aleo` and `pncw_payroll.aleo`:  
  - Use escrow record w/ `status` field  
  - Wait for Stellar SDK payout confirmation  
  - Trigger NFT mint after tx is verified  
  - Consume payroll record and hash audit to chain  

### Phase 5 – NFT Paystub Layer  
- `paystub_nft.aleo`:  
  - Private, field-by-field viewing  
  - Bound to `.pnw` identity  
  - Tenure score + hashed audit metadata  
  - ZPass-style resume for future employers  

---

## 🧠 Core Smart Contracts

| File                         | Description |
|------------------------------|-------------|
| `worker_profiles.aleo`       | Identity and credential hashing for workers |
| `employer_profiles.aleo`     | Employer credential verification |
| `employer_agreement.aleo`    | Contract link between worker, employer, subDAO |
| `aleo_gas_station.aleo`      | ALEO prefunding checker |
| `stellar_gas_station.aleo`   | USDC + tax prefunding logic |
| `pniw_payroll.aleo` / `pncw_payroll.aleo` | Triggered escrow-based payroll contracts |
| `paystub_nft.aleo`           | Private NFT receipt system |
| `pnw_name_registry.aleo`     | Worker/Employer .pnw suffix name system |

---

## 🌐 .pnw Name Registry

All platform users must have a registered `.pnw` identity:

| Suffix      | Type           |
|-------------|----------------|
| `.svc.pnw`  | Service Employer |
| `.bld.pnw`  | Construction Employer |
| `.wrk.pnw`  | Worker (any)   |
| ...         | (More industry types supported) |

- Soulbound  
- Verified once per unique identity  
- Required to execute platform transactions  

---

## 💸 Gas + Payout Flow (Hybrid Escrow)

1. Employer registers a worker and contract duration  
2. Required ALEO + USDC prefund amount is calculated:
   - **1 ALEO / 90 days / worker**
   - **1 USDC + 30% for taxes / cycle**
3. Escrow record is created and submitted  
4. Stellar SDK triggers payout and confirms tx hash  
5. NFT paystub is minted for worker  
6. Record is consumed and audit hash is stored  

---

## 📦 Front-End & SDK Integration

| Folder | Role |
|--------|------|
| `front_end/` | Receives Stellar wallet input from workers |
| `stellar_handler.js` | Horizon SDK tx manager |
| `stellar_tx_log.js` | Privacy-preserving audit file |
| `worker_submit.js` | Aleo credential + wallet linker |
| `index.html` | DApp interface for mobile / onboarding |

---

## 🔐 Privacy Enforcement

- Poseidon2 Hashing  
- Escrow records with internal `status`  
- NFT fields only viewable by authorized entities  
- No raw identity data exposed  
- Payment hashes stored in separate audit logs (`payroll_hash_log.aleo`)

---

## 📍 Live (Planned)

- [ ] Stellar testnet wallet handling  
- [ ] .wasm + SNARKVM proof integration  
- [ ] DAO-based NFT attestation  
- [ ] Optional staking pool for ALEO gas coverage  
- [ ] Mobile-first onboarding UI  

---

## 🛠 Built With

- **Aleo** for private, verifiable state and .wasm proofs  
- **Leo 2.6+** language for smart contracts  
- **Stellar Horizon SDK** for external gas and USDC delivery  
- **Poseidon2 / Plonky2** for ZK hashing & proof composition  
- **ZPass** pattern NFT privacy architecture  

---

## 🤝 Licensing & Attribution

PNW-MVP is protected under a **proprietary license**.

**No reuse, derivative work, or forking is allowed** without written permission from the author.

Please refer to `LICENSE_PNW_MVP.txt` in the root folder.

---

**PNW-MVP: Empowering workers through zero-knowledge privacy.**
