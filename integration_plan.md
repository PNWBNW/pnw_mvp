# 📌 PNW-MVP Technical Integration Plan

## 🚀 Overview
This document outlines the technical integration plan for the **PNW-MVP** zero-knowledge payroll system, detailing contract dependencies, deployment flow, and system interactions.

---

## 📂 **1. Project Structure & Contract Dependencies**
The project consists of **modular smart contracts**, each handling a distinct part of the payroll and compliance system.
Each contract has its **own `leo.toml`**, ensuring modularity and structured deployment.

---

## 🔄 **2. Contract Dependencies & Interaction Flow**
Each contract interacts with others **in a structured manner**, ensuring payroll compliance and fund distribution:

### **A. Core Contracts**
- ✅ **`credits`** - Handles token balances, transfers, and payroll funding.
- ✅ **`employer_agreement`** - Registers employers and links worker identities.

### **B. Payroll Processing**
- ✅ **`pncw_payroll` & `pniw_payroll`** - Handle payroll for full-time and contract workers.
- ✅ **`weekly_payroll_pool`** - Distributes payroll funds on a scheduled basis.

### **C. Compliance & Fund Management**
- ✅ **`process_tax_compliance`** - Ensures payroll meets tax obligations.
- ✅ **`subdao_reserve`** - Manages funding from SubDAOs.
- ✅ **`oversightdao_reserve`** - Ensures payroll compliance and fund allocation.

---

## ⚙️ **3. Deployment Flow**
To ensure a smooth deployment, contracts will be deployed **in the following order:**

1️⃣ **Credits Contract**
   - Initializes core token balance tracking.

2️⃣ **Employer Agreement**
   - Registers employers and verifies worker identities.

3️⃣ **Fund Distribution Contracts** *(Parallel Deployment)*
   - `process_tax_compliance`
   - `weekly_payroll_pool`
   - `subdao_reserve`
   - `oversightdao_reserve`

4️⃣ **Payroll Contracts**
   - `pncw_payroll`
   - `pniw_payroll`

---

## 🚀 **4. Integration with Aleo Testnet**
### **A. Funding & Wallet Setup**
- Developers **must obtain testnet tokens** via [Aleo Faucet](https://discord.com/invite/aleo).
- Wallet private key (`ALEO_PRIVATE_KEY`) is set as an environment variable.

### **B. Deployment Command**
Contracts are deployed using the optimized script:

```bash
./deploy_pnw_mvp.sh

Future Enhancements

✅ Transition to Mainnet Integration

✅ Further Optimization of Payroll Processing

✅ Expanding Compliance Verification Features

✅ Improved Logging & Audit Trails for OversightDAO
