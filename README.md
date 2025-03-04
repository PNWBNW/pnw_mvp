# PNW-MVP

## Overview
PNW-MVP is a **privacy-focused payroll processing system** built on the Aleo blockchain.  
It uses **Aleo Name Service (ANS)** for worker and employer identities, **ZPass verification**, and **smart contracts** for automated payments, compliance, and taxation.

## Features
- **Worker & Employer Registration** via ANS (`worker.pniw.ans`, `employer.pnw.ans`)
- **Automated Payroll Processing** with subDAO reserves
- **Tax Compliance Management** with direct payments to tax authorities
- **Weekly Payroll Pool Funding** for secure batch payments
- **Full Byte Hash Optimization** for efficient storage and validation

## Prerequisites
- Aleo CLI (`leo-lang`)
- Rust & Cargo
- A registered **ANS domain**
- A funded **Aleo testnet wallet**

## Installation
### **1️⃣ Clone the Repository**

git clone https://github.com/PNWBNW/PNW-MVP.git cd PNW-MVP

### **2️⃣ Install Dependencies**

sudo apt update && sudo apt install -y curl bash unzip git rustc cargo cargo install leo-lang

### **3️⃣ Set Up Your Aleo Private Key**

export ALEO_PRIVATE_KEY="your-private-key-here"

Or store it securely in GitHub Actions as `secrets.ALEO_PRIVATE_KEY`.

## Deployment
### **Run Locally**

leo clean && leo build leo deploy --private-key="$ALEO_PRIVATE_KEY" --network testnet

### **Deploy with GitHub Actions**
1. **Push to `main` branch**  
2. **GitHub Actions will run the deployment pipeline automatically**  
3. **Monitor logs under "Actions" tab in GitHub**

## Smart Contracts & Usage

### **Register a Worker**

leo run register_worker "johndoe.pniw.ans" 0 1 "ZPassHashPlaceholder"

### **Register an Employer**

leo run register_employer "employer.pnw.ans"

### **Fund Payroll Pool**

leo run fund_payroll_pool "wa001_subdao.pnw.ans" 1000

### **Execute Weekly Payroll**

leo run execute_weekly_payroll "johndoe.pniw.ans" "wa001_subdao.pnw.ans" 100 "ZPassHashPlaceholder"

## Troubleshooting
### **Error: `Failed to deserialize program.json`**
- **Run `leo clean && leo build` before deployment.**
- **Ensure `program.json` contains `"license": "Proprietary"`.**

### **Error: `Missing Private Key`**
- **Check if `$ALEO_PRIVATE_KEY` is correctly exported.**
- **For GitHub Actions, ensure it's stored in `secrets.ALEO_PRIVATE_KEY`.**

## License
This software is licensed under a **Proprietary License**.  
Unauthorized distribution or modification is strictly prohibited.

