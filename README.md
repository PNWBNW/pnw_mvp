📌 PNW-MVP: Zero-Knowledge Payroll System

Version: 25.3.14
Edition: 2025.3
Network: Aleo Testnet


---

🚀 Overview

PNW-MVP is a zero-knowledge payroll system built on the Aleo blockchain, ensuring privacy-preserving payroll processing, employer verification, tax compliance, and fund distribution. Using Aleo’s zk-SNARKs, payroll calculations and transactions remain private while maintaining full compliance and transparency within a decentralized structure.

This document serves as both a technical integration plan and a deployment guide, outlining the contract architecture, deployment process, and system interactions.


---

📂 Project Structure

Each contract is modular and self-contained, ensuring flexibility and clear dependency management. Every contract exists within its own directory, containing a main.leo file for logic and a leo.toml for package management.

pnw_mvp/
├── src/
│   ├── credits/
│   ├── employer_agreement/
│   ├── process_tax_compliance/
│   ├── weekly_payroll_pool/
│   ├── subdao_reserve/
│   ├── oversightdao_reserve/
│   ├── pncw_payroll/
│   ├── pniw_payroll/
├── deploy_pnw_mvp.sh
├── deploy.yml
├── program.json
├── README.md


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




Each contract is deployed from its respective directory using the Aleo CLI.

leo deploy --network testnet --path src/credits --private-key ${ALEO_PRIVATE_KEY}

Alternatively, use the automated deployment script:

./deploy_pnw_mvp.sh


---

🔗 Integration with Aleo Testnet

To interact with Aleo Testnet, obtain testnet tokens via Aleo’s Discord Faucet and configure your private key for contract deployment.

export ALEO_PRIVATE_KEY="your_private_key_here"

Ensure your wallet is funded before initiating payroll transactions.


---

🛠 Debugging & Error Handling

Common Errors

Exit 248: Failed contract parsing. Ensure leo.toml and main.leo are correctly structured.

Exit 13: Missing leo.toml or main.leo in contract directory.

Exit 2: Incorrect CLI command usage.


Debugging Tools

Use CheatCode::print_mapping() to debug mappings.

Run test deployments before executing payroll transactions.


program debug_test.aleo {
    mapping test_mapping: address => u64;
    function debug_test() -> u64 {
        CheatCode::print_mapping(test_mapping);
        return 1u64;
    }
}

Run the debug contract:

leo run --network testnet debug_test.aleo debug_test


---

📅 Future Enhancements

Mainnet Transition - Preparing for full deployment on Aleo Mainnet.

Optimized Payroll Execution - Enhancing contract efficiency.

Expanded Compliance Validation - Strengthening tax and regulatory compliance.

Audit Logging for OversightDAO - Providing deeper visibility into payroll compliance.



---

🔥 Conclusion

PNW-MVP delivers a decentralized, private, and compliant payroll solution using Aleo’s zk-SNARKs. By following this integration plan, developers can deploy, manage, and scale a privacy-preserving payroll system efficiently.


---

🔥 Chef, this is a fully structured, deploy-ready technical document! Let me know if you'd like refinements. 🧑🏽‍🍳🚀

