---

process_tax_compliance/README.md

# process_tax_compliance.aleo

The `process_tax_compliance` program tracks and manages employer tax records for payroll events in the PNW MVP system.

This contract is intentionally modular and **does not perform external transfers or audit logging directly**.  
All external system hooks (e.g. for audit logging) will be called via `coordinator_program/router_main.aleo`.

## Purpose

- Maintain employer tax payment records
- Track total tax paid and last payment block per employer
- Allow payroll processing pipelines to report taxes in a standardized way

## Data Model

### Mappings

```leo
mapping employer_tax: address => EmployerTaxRecord;

Structs

struct EmployerTaxRecord {
    employer_address: address,
    total_tax_paid: u64,
    last_payment_block: u32,
    is_compliant: bool
}

employer_address = address of the employer

total_tax_paid = total tax paid by employer

last_payment_block = block height of last payment event

is_compliant = current compliance flag


Transitions

process_tax_compliance

async transition process_tax_compliance(employer_address: address, payroll_type: u8, block_height: u32) -> Future

Adds a new tax payment for employer_address.
Calculates tax based on payroll_type:

0 = standard payroll

1 = alternate payroll

2+ = no tax owed


The block_height must be passed in externally (by coordinator).

An audit log hook is left for future integration:

// router will later call: payroll_audit_log::record_tax_payment(employer_address, tax_due)

verify_tax_record

async transition verify_tax_record(employer_address: address) -> Future

Verifies that an employer has a tax record entry.

Functions

calculate_tax_due

function calculate_tax_due(payroll_type: u8) -> u64

Simple hard-coded tax logic for MVP:

0 = 1000

1 = 500

else = 0


Design Principles

Fully modular: no external imports or dependencies

Router-ready: designed to plug into coordinator funnels via coordinator_program

Safe: all mappings use default fallback values to avoid failures

Upgradeable: future versions can expand tax rules or call audit logs directly

