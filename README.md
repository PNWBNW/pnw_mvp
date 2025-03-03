🚀

# PNW-MVP: Payroll Infrastructure

A zero-knowledge payroll system built on Aleo Testnet, designed for employer-managed worker payments while ensuring compliance and transparency.

## 🔥 Features
✅ **ANS-Based Identity** – Uses `worker_ans`, `employer_ans`, and `subdao_ans` instead of raw addresses.  
✅ **ZPass Verification** – Workers must have a verified `zpass_hash: [u8; 64]` before payroll execution.  
✅ **Decentralized Payroll Management** – Supports employer-funded SubDAO structures.  
✅ **Automatic Tax Compliance** – Employers must process taxes before paying workers.  
✅ **Byte Hash Optimizations** – Maximum use of `[u8; 32]` for efficiency and security.  

---

## **📌 Smart Contracts**
| Contract | Description |
|----------|------------|
| `employer_agreement.aleo` | Employer funding entry point. |
| `subDAO_reserve.aleo` | Manages payroll funds & tax obligations. |
| `weekly_payroll_pool.aleo` | Weekly worker payouts. |
| `oversightDAO_reserve.aleo` | 17% oversight compliance reserve (ANS: `oversightdao.pnw.ans`). |
| `main.leo` | Core orchestration of payroll execution. |
| `process_tax_compliance.aleo` | Ensures employer tax payments before payroll. |

---

## **🛠 Setup & Installation**
### **1️⃣ Install Leo CLI (Latest Testnet Version)**
```sh
cargo install leo-lang
leo --version

2️⃣ Clone & Build the Project

git clone <repo-url>
cd PNW-MVP
leo build

3️⃣ Run Tests

Execute tests with:

leo run test_<transition>

Example:

leo run main_test.test_register_worker

See tests/ directory for available test cases.



---

🚀 Deployment

1️⃣ Local Deployment

leo deploy --network testnet --private-key <your-test-key>

2️⃣ GitHub Actions Deployment

1. Add your test private key to GitHub Secrets as Aleo_test_key.


2. Push to main branch to trigger deployment.




---

💰 Payroll Flow (ANS-Based Execution)

Step-by-step process using ANS-based worker and employer identities.

1️⃣ Fund Payroll Pool

leo run fund_payroll_pool wa001_subdao.pnw.ans 1000u64

2️⃣ Process Taxes

leo run process_taxes wa001_subdao.pnw.ans

3️⃣ Fund Weekly Payroll Pool

leo run fund_weekly_pool wa001_subdao.pnw.ans 700u64

4️⃣ Pay Worker (ZPass-Verified)

leo run pay_worker johndoe.pniw.ans wa001_subdao.pnw.ans 100u64 ZPassHashPlaceholder


---

📜 Governance & Oversight

SubDAO Funds → Direct employer deposits (1:1 match).

OversightDAO Reserve → Receives 17% of employer payments for compliance.

Tax Processing → Employers must process taxes before payroll.

---

🌎 Future Enhancements

🔹 Multi-DAO Expansion – Support for regional SubDAOs.
🔹 Automated Payroll Schedules – Workers can receive payouts based on set intervals.
🔹 Cross-Chain Payroll – Support for Aleo-to-EVM payroll bridges.


---

🚀 Ready to Deploy?

Run:

leo deploy --network testnet --private-key <your-test-key>

🔥 PNW-MVP is fully optimized & production-ready. 🔥

---


