#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."

# Ensure Leo CLI is Executable
chmod +x pnw_mvp/directory/.aleo/leo

# Step 1: Define Deployment Contracts in Optimized Order
CONTRACTS=(
    "src/credits"
    "src/employer_agreement"
    "src/process_tax_compliance"
    "src/weekly_payroll_pool"
    "src/subdao_reserve"
    "src/oversightdao_reserve"
    "src/pncw_payroll"
    "src/pniw_payroll"
)

# Step 2: Deploy Contracts (Log Each Deployment)
echo "🚀 Deploying Contracts in Optimized Order..."
for contract in "${CONTRACTS[@]}"; do
    echo "🚀 Deploying: $contract"
    if ! pnw_mvp/directory/.aleo/leo deploy --network testnet --path $contract --private-key ${ALEO_PRIVATE_KEY} 2>&1 | tee -a deploy_log.txt; then
        echo "🚨 Deployment failed for $contract!"
        exit 248
    fi
done

echo "✅ PNW-MVP Deployment Complete!"
