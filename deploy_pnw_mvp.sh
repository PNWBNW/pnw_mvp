#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."

# Load environment variables from .env file
if [ -f "pnw_mvp/.env" ]; then
    export $(grep -v '^#' pnw_mvp/.env | xargs)
    echo "🌍 Using network: $NETWORK"
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Ensure Leo CLI is Executable
chmod +x pnw_mvp/directory/.aleo/leo

# Step 1: Define Deployment Contracts in Optimized Order
CONTRACTS=(
    "pnw_mvp/src/credits"
    "pnw_mvp/src/employer_agreement"
    "pnw_mvp/src/process_tax_compliance"
    "pnw_mvp/src/weekly_payroll_pool"
    "pnw_mvp/src/subdao_reserve"
    "pnw_mvp/src/oversightdao_reserve"
    "pnw_mvp/src/pncw_payroll"
    "pnw_mvp/src/pniw_payroll"
)

# Step 2: Deploy Contracts (Using Correct Paths)
echo "🚀 Deploying Contracts in Optimized Order..."
for contract in "${CONTRACTS[@]}"; do
    echo "🚀 Deploying: $contract"

    # Validate Paths Before Deployment
    if [ ! -f "$contract/leo.toml" ]; then
        echo "❌ Error: Missing leo.toml in $contract!"
        exit 248
    fi
    if [ ! -f "$contract/main.leo" ]; then
        echo "❌ Error: Missing main.leo in $contract!"
        exit 248
    fi

    # Execute Deployment
    if ! pnw_mvp/directory/.aleo/leo deploy --network $NETWORK --path $contract --private-key ${ALEO_PRIVATE_KEY} 2>&1 | tee -a deploy_log.txt; then
        echo "🚨 Deployment failed for $contract!"
        exit 248
    fi
done

echo "✅ PNW-MVP Deployment Complete!"
