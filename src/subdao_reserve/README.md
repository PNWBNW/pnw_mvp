# subdao_reserve.aleo

The `subdao_reserve` program manages internal reserve balances and tax obligations for each subDAO in the PNW MVP system.

This contract is intentionally designed as a **modular internal balance ledger**, with no external dependencies or imports.  
All external calls (such as transfers or payroll funding) are routed via `coordinator_program/router_main.aleo` using branch logic.

## Purpose

- Allow subDAOs to deposit and withdraw funds from their internal reserve pool
- Track and update tax obligations per subDAO
- Serve as the main internal treasury contract for subDAO funds

## Data Model

### Mappings

```leo
mapping reserve_balance: address => u64;
mapping tax_obligations: address => u64;
