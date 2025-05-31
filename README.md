# Proven Noncitizen Workers (PNW-MVP)

**A privacy-focused digital payroll and compliance system built for agricultural workers, independent contractors, and small employers — powered by zero-knowledge cryptography.**

---

## What Is PNW-MVP?

The **PNW-MVP** project is a modular system built to help **farmers, workers (citizen and noncitizen), and employers** manage payroll and taxes securely — without paperwork, intermediaries, or data exposure.

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
- `employer_profiles.aleo` – Mirrors worker logic for employers, storing attested credentials privately ✅
- `employer_registry.aleo` – Manages employers and linked SubDAO funds
- `credential_nft.aleo` – Soulbound badge NFT system for worker certification
- `oversightdao_nft.aleo` – NFT badge system for SubDAO or audit-level employer credentials ✅
- `pncw_payroll` & `pniw_payroll` – Weekly payroll streams by classification
- `oversightdao_reserve` – Reserve held for DAO-approved audits and compliance
- `subdao_reserve` – Local pools for community-led pay and tax contributions

---

## How Plonky2 Proving Works

PNW-MVP integrates a **hybrid off-chain ZK proof flow** using [Plonky2](https://github.com/mir-protocol/plonky2) to enhance credential verification for both **workers and employers**.

---

### 🔧 Frontend ZPass Flow for Workers

1. A worker fills out a form (name, city, state, credential list).
2. The frontend generates a **recursive Plonky2 proof**.
3. This proof produces a unique **credential hash** using `poseidon2` with optional NFT-gated logic.
4. The hash is sent to the `worker_profiles.aleo` contract along with u128-encoded identity fields.
5. Optionally, a DAO agent mints a **ZPass badge** from `credential_nft.aleo`.

The result: Workers can prove who they are, what they’re certified for — without ever exposing raw data.

---

### 🏢 ZK Attestation Flow for Employers (NEW)

Employers follow a nearly identical flow:

1. A cooperative or agent fills out the employer’s business profile (e.g., EIN, state, license class).
2. The system creates a **Plonky2 proof** of that attestation.
3. A `poseidon2` hash is generated to commit the employer profile.
4. This credential hash is stored in `employer_profiles.aleo`, along with optional u128 metadata.
5. Optionally, the DAO mints a **compliance NFT** for the employer from `oversightdao_nft.aleo`.

This enables employers to **prove audit status and compliance** — without revealing proprietary or regulatory-sensitive info.

---

## Privacy & Security

PNW-MVP uses **zero-knowledge cryptography and recursive proving** to:

- Prove worker certification, payroll eligibility, and location-based access
- Prove employer compliance and license validity
- Protect sensitive worker and employer identities
- Prevent double-registration, impersonation, or manipulation

All data lives on-chain, encrypted — and only the proof is public.

---

## Built With

- **Aleo Blockchain**: For scalable ZK contracts and private on-chain state
- **Leo Language**: Smart contract DSL optimized for zero-knowledge
- **Plonky2**: Recursive proof system for off-chain credential processing
- **Poseidon2**: Native hash function for low-cost zk commitment generation

---

## What’s Next?

- ✅ ZPass credential loader with NFT gate logic for worker onboarding
- ✅ Credential hash attestation for employer profiles
- Launch mobile-friendly UI for both roles
- Integrate employer tax payment escrow system
- Allow DAOs to issue employer compliance NFTs
- Launch pilot program in rural labor region

---

## Contribute / Learn More

- [aleo.org](https://aleo.org)
- [github.com/ProvableHQ](https://github.com/ProvableHQ)
- [Plonky2](https://github.com/mir-protocol/plonky2)

---

**PNW-MVP believes in privacy, dignity, and security for all — no matter your passport or payroll.**
