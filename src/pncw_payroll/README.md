--

pncw_payroll/README.md

# pncw_payroll.aleo

The `pncw_payroll` program manages payroll funding and distribution balances for PNCW workers in the PNW MVP system.

This contract is intentionally modular and **does not perform credits transfers or audit logging directly**.  
All external transfers and audit calls will be routed via `coordinator_program/router_main.aleo`.

## Purpose

- Allow employers to pre-fund payroll for their PNCW workers
- Allow payroll processing to deduct funds and distribute balances
- Maintain safe internal accounting records for each worker and employer

## Data Model

### Mappings

```leo
mapping employer_funding: address => u64;
mapping worker_balances: address => u64;

employer_funding = internal credits available for an employer to pay workers

worker_balances = internal balance owed to worker prior to external payout


Transitions

fund_payroll

async transition fund_payroll(employer: address, amount: u64) -> Future

Adds amount to the internal funding pool for employer.
Only positive non-zero amounts allowed.

execute_payroll

async transition execute_payroll(worker: address, employer: address, amount: u64) -> Future

Moves amount from the employer's balance into the worker's internal balance.
Validations:

Employer must have sufficient funding

Positive non-zero amounts only


An audit hook is left for coordinator to attach:

// coordinator_program will later call:
// credits::transfer_public(worker, amount)
// payroll_audit_log::record_payment(worker, amount, block_height)

verify_worker_balance

async transition verify_worker_balance(worker: address) -> Future

Asserts that a worker has a recorded balance entry.

Functions

verify_worker_balance_amount

inline verify_worker_balance_amount(worker: address) -> u64

Allows external contracts to query a worker’s current internal balance.

Design Principles

Fully modular: no external imports or dependencies

Router-ready: designed to plug into coordinator funnels

Safe: all balance changes use internal checks

Upgradeable: future versions can extend with audit tracking or events

