#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."

# Load environment variables from .env
if [ -f "$GITHUB_WORKSPACE/.env" ]; then
    export $(grep -v '^#' "$GITHUB_WORKSPACE/.env" | xargs)
    echo "🌍 Using network: ${NETWORK:-testnet}"
else
    echo "❌ Error: .env file not found!"
    exit 1
fi

# Ensure Leo CLI is executable
chmod +x "$GITHUB_WORKSPACE/directory/.aleo/leo"

# Change to the workspace root
cd "$GITHUB_WORKSPACE" || { echo "❌ Could not enter repository root."; exit 1; }

# Define contract paths relative to workspace root
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

    # List contents for debugging
    echo "🔍 Listing files in $contract_dir:"
    ls -la "$contract_dir"

    echo "📄 Content of $contract_dir/leo.toml:"
    cat "$contract_dir/leo.toml"

    # Check required files
    if [ ! -f "$contract_dir/leo.toml" ]; then
        echo "❌ Error: Missing leo.toml in $contract_dir!"
        exit 248
    fi

    if [ ! -f "$contract_dir/main.leo" ]; then
        echo "❌ Error: Missing main.leo in $contract_dir!"
        exit 248
    fi

    # Run deployment
    if ! "$GITHUB_WORKSPACE/directory/.aleo/leo" deploy \
        --network testnet \
        --path "$contract_dir" \
        --private-key "$ALEO_PRIVATE_KEY" \
        2>&1 | tee -a deploy_log.txt; then
        echo "🚨 Deployment failed for $contract_dir!"
        exit 248
    fi
done

echo "✅ PNW-MVP Deployment Complete!"
