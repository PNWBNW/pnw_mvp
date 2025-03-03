
# Worker Profiles Using ANS for Workers & SubDAOs + ZPass ID Verification

This directory contains **custom employer-configured worker profiles**, using:
✔ **Aleo Name Service (ANS) for workers & SubDAOs**  
✔ **ZPass ID verification for worker identity compliance**  
✔ **A CLI script to automate worker registration**  

---

## **1️⃣ Customizing `employer_worker_config.json`**
Each employer **must create and maintain** their own JSON file following this structure:

### **Example: `employer_worker_config.json`**
```json
{
  "employer_name": "ACME Inc.",
  "employer_id": "aleo1employerxyz...",
  "subdao_ans": "wa001_subdao.pnw.ans",
  "workers": [
    {
      "worker_ans": "johdoe.pniw.ans",
      "worker_address": "aleo1worker123...",
      "zpass_id": "ZP-20250314-001",
      "category": 1,
      "verified": true
    },
    {
      "worker_ans": "janesmith.pncw.ans",
      "worker_address": "aleo1worker456...",
      "zpass_id": "ZP-20250314-002",
      "category": 2,
      "verified": false
    }
  ]
}

---

Field Definitions


---

2️⃣ Running the CLI Script

Aleo employers should use register_workers.sh to batch register workers.

📌 Steps to Execute

1. Ensure employer_worker_config.json is correctly formatted.


2. Make the script executable:

chmod +x register_workers.sh


3. Run the script:

./worker_profiles/register_workers.sh



💡 How It Works

Reads employer_worker_config.json

Extracts each worker’s ANS name, ZPass ID, and wallet address

Calls the Aleo contract register_worker transition:

leo run register_worker <worker_address> <category> <subdao_ans> <zpass_id>



---

3️⃣ Common Issues & Troubleshooting


---

4️⃣ Future Enhancements

✅ Logging worker registration outputs
✅ Batch processing optimization for large workforce files
✅ Automatic ANS & ZPass validation before registration


---

🚀 Need Help?

For support, open an issue on the PNW-MVP GitHub Repository or contact the DAO administrator.
