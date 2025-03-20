#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."

# Load environment variables
if [ -f "$GITHUB_WORKSPACE/.env" ]; then
    export $(grep -v '^#' "$GITHUB_WORKSPACE/.env" | xargs)
    echo "🌍 Using network: ${NETWORK:-testnet}"  # Defaults to testnet if NETWORK is unset
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Ensure Leo CLI is Executable
chmod +x "$GITHUB_WORKSPACE/directory/.aleo/leo"

# Change Directory to the Repository Root
cd "$GITHUB_WORKSPACE" || { echo "❌ Error: Could not enter repository root!"; exit 1; }

# Define Deployment Contracts with Correct Paths
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

echo "🚀 Deploying Contracts in Optimized Order..."
for contract_dir in "${CONTRACTS[@]}"; do
    echo "🚀 Deploying: $contract_dir"

    # Debugging: Show directory contents before deployment
    echo "🔍 Listing files in $contract_dir:"
    ls -la "$contract_dir" || echo "⚠️ Warning: $contract_dir does not exist!"

    # Validate Paths Before Deployment
    if [ ! -f "$contract_dir/leo.toml" ]; then
        echo "❌ Error: Missing leo.toml in $contract_dir!"
        exit 248
    fi
    if [ ! -f "$contract_dir/main.leo" ]; then
        echo "❌ Error: Missing main.leo in $contract_dir!"
        exit 248
    fi

    # Execute Deployment with Explicit Testnet Usage
    if ! "$GITHUB_WORKSPACE/directory/.aleo/leo" deploy --network testnet --path "$contract_dir" --private-key ${ALEO_PRIVATE_KEY} 2>&1 | tee -a deploy_log.txt; then
        echo "🚨 Deployment failed for $contract_dir!"
        exit 248
    fi
done

echo "✅ PNW-MVP Deployment Complete!"
