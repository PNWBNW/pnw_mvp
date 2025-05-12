-

weekly_payroll_pool/README.md

# weekly_payroll_pool.aleo

The `weekly_payroll_pool` program manages weekly payroll funding balances for subDAOs in the PNW MVP system.

This contract is intentionally modular and **does not perform external payments or worker transfers directly**.  
All real fund movement is routed via `coordinator_program/router_main.aleo` using branch logic.

## Purpose

- Allow subDAOs to deposit weekly payroll funds into their pool
- Track and manage internal weekly balances
- Allow payroll execution (debit) from pool balances

## Data Model

### Mappings

```leo
mapping weekly_balance: address => u64;

weekly_balance = current available weekly funds for each subDAO.


Transitions

fund_weekly_pool

async transition fund_weekly_pool(subdao_address: address, amount: u64) -> Future

Deposits amount into the subDAO's weekly pool.
Only positive non-zero amounts are allowed.

execute_weekly_payroll

async transition execute_weekly_payroll(subdao_address: address, amount: u64) -> Future

Debits amount from the subDAO's weekly pool.
This simulates funding a payroll batch internally.

verify_pool_exists

async transition verify_pool_exists(subdao_address: address) -> Future

Confirms that a subDAO's weekly pool exists and has a recorded balance entry.

Design Principles

Fully modular: no external imports or dependencies

Router-ready: designed to plug into external funnels via coordinator_program

Safe: all operations perform internal assertions to avoid negative balances

Upgradeable: future versions can extend functionality with minimal risk

