# 🌍 Proven National Worker (PNW) - MVP Payroll System

### **🚀 Overview**
This is the **Minimum Viable Product (MVP)** for the **PNW Payroll System**, integrating **Aleo & Aztec smart contracts** for **secure, private, and compliant payroll processing**.

### **📜 Included Contracts**
#### **🔹 Aleo Contracts**
- **Payroll Processing**
  - `pncw_payroll.leo` → PNcW (Citizen Workers) payroll
  - `pniw_payroll.leo` → PNiW (Immigrant Workers) payroll
- **Governance & Compliance**
  - `employer_agreement.leo` → Employer compliance enforcement
  - `process_tax_compliance.leo` → Employer tax processing
  - `compliance_tracking.leo` → Certification & worker compliance
  - `subdao_governance.leo` → Worker-led payroll governance
- **Fund Management**
  - `subdao_aleo_usdc_reserve.leo` → Payroll fund reserve
  - `oversightdao_combined_reserve.leo` → Emergency payroll reserves

#### **🔹 Aztec Contracts**
- `aztec_payroll.noir` → Private payroll execution on Aztec
- `subdao_circle_usdc_reserve.noir` → SubDAO-controlled Circle USDC reserve

---

### **🛠 Deployment Guide**
#### **🔹 Using Shell Script (`deploy.sh`)**
```sh
chmod +x deploy.sh
./deploy.sh

---

📢 Development Notice: Time-Locked Shuffle Encryption

We are actively developing a Time-Locked Shuffle Encryption System that integrates:
✅ AES-style encryption for worker/employer confidentiality
✅ zk-SNARK-based proof shuffling to anonymize payroll and transaction data
✅ One-time shuffle maps to prevent traceability after decryption
✅ Time-lock expiries to enforce controlled access and delayed key release

This system is designed to enhance privacy, security, and fair enforcement of payroll distributions within the PNW ecosystem.

⏳ Status: In Progress – Integration pending for SubDAO-managed payroll and trust fund distributions.


---

