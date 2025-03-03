
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
