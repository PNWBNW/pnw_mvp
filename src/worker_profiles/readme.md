---

worker_profiles/README.md

# worker_profiles.aleo

The `worker_profiles` program is part of the PNW MVP system and provides a self-sovereign, private, and decentralized registry for worker metadata on-chain.

## Purpose

- Allow workers to register their identity and employment metadata in a secure, auditable, yet fully private manner.
- Allow affiliated subDAOs to manage and verify worker registration in compliance with internal governance standards.
- Eliminate reliance on external global name registries.

## Data Model

### Worker Struct

```leo
struct Worker {
    is_pniw: bool,                      // true = PNiW, false = PNCW
    country_of_origin: [u8; 3],         // ISO country code (if PNiW only)
    industry_code: u8,                  // Industry code (1–15)
    has_dependents: bool,               // Tax filing flag
    state_of_residency: [u8; 2],        // US state abbreviation (e.g., "CA")
    subdao_affiliation: address,        // Address of subDAO the worker is affiliated with
    _nonce: group                       // Randomized salt for privacy
}

Registration Workflow

A worker calls register_worker() with their data payload.

If is_pniw == false (PNCW), the country_of_origin must be zeroed ([0u8, 0u8, 0u8]).

Industry code must be within range 1..=15.


Industry Code Mapping

Code	Industry

1	Agriculture
2	Construction
3	Retail & Consumer Services
4	Legal & Compliance (Law)
5	Healthcare & Medical
6	Manufacturing
7	Transportation & Logistics
8	Hospitality & Food Services
9	Education & Childcare
10	Energy & Utilities
11	Information Technology
12	Government & Public Services
13	Finance & Banking
14	Arts, Entertainment & Media
15	Other / Unclassified


Design Principles

Self-sovereign: Worker identity data is controlled and updated solely by the worker.

Privacy-preserving: No human-readable names are stored on-chain. All data is internal to PNW contracts.

Extensible: Future fields such as certifications, worker hashes, or employment status can be added as needed.

SubDAO compatible: Each worker is linked to a subDAO for auditability and governance.


