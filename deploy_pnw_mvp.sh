#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."

# Step 1: Ensure Leo CLI is Executable
chmod +x pnw_mvp/Directory/.aleo/leo

# Step 2: Define Deployment Contracts in Optimized Order
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

# Step 3: Deploy Contracts
echo "🚀 Deploying Contracts in Optimized Order..."
for contract in "${CONTRACTS[@]}"; do
    echo "🚀 Deploying: $contract"
    if ! pnw_mvp/Directory/.aleo/leo deploy --network testnet --path $contract --private-key ${ALEO_PRIVATE_KEY}; then
        echo "🚨 Deployment failed for $contract!"
        exit 248
    fi
done

echo "✅ PNW-MVP Deployment Complete!"
