📌 PNW-MVP: Zero-Knowledge Payroll System

Version: 25.3.14
Edition: 2025.3
Network: Aleo Testnet


---

🚀 Overview

PNW-MVP is a zero-knowledge payroll system built on the Aleo blockchain, ensuring privacy-preserving payroll processing, employer verification, tax compliance, and fund distribution. Using Aleo’s zk-SNARKs, payroll calculations and transactions remain private while maintaining full compliance and transparency within a decentralized structure.

This document serves as both a technical integration plan and a deployment guide, outlining the contract architecture, deployment process, and system interactions.


---

🔄 Contract Dependencies & Functionality

Credits Contract

Handles the core payroll token system, tracking balances, payroll distributions, and employer allocations. Required for all financial transactions in the system.

Employer Agreement

Registers employers, manages employer-worker relationships, and validates that only verified employers can issue payroll.

Payroll Processing

Manages payroll execution for both full-time and independent workers. Employers interact with the payroll contracts to initiate disbursements.

Weekly Payroll Pool

Receives and distributes payroll funds on a scheduled basis, ensuring worker compensation follows a structured process.

Tax Compliance Contract

Ensures payroll meets regulatory requirements, verifying that funds allocated for taxes are correctly deducted.

SubDAO Reserve

Manages funding distribution for payroll and compliance. This contract serves as the funding source for payroll execution.

OversightDAO Reserve

Monitors and audits payroll transactions for compliance, ensuring that payroll funds are used correctly.


---

⚙️ Deployment Order & Process

To maintain proper execution, contracts must be deployed in order, ensuring dependencies are met.

1. Credits Contract - Initializes payroll tokens and financial transactions.


2. Employer Agreement - Registers employer identities and permissions.


3. Core Fund Allocation

Process Tax Compliance

Weekly Payroll Pool

SubDAO Reserve

OversightDAO Reserve



4. Payroll Contracts

PNCW Payroll (Full-Time Workers)

PNIW Payroll (Independent Workers)

