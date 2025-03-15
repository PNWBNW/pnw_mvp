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

# Step 1: Define Deployment Contracts with Explicit Paths for leo.toml and main.leo
CONTRACTS=(
    "pnw_mvp/src/credits/leo.toml pnw_mvp/src/credits/main.leo"
    "pnw_mvp/src/employer_agreement/leo.toml pnw_mvp/src/employer_agreement/main.leo"
    "pnw_mvp/src/process_tax_compliance/leo.toml pnw_mvp/src/process_tax_compliance/main.leo"
    "pnw_mvp/src/weekly_payroll_pool/leo.toml pnw_mvp/src/weekly_payroll_pool/main.leo"
    "pnw_mvp/src/subdao_reserve/leo.toml pnw_mvp/src/subdao_reserve/main.leo"
    "pnw_mvp/src/oversightdao_reserve/leo.toml pnw_mvp/src/oversightdao_reserve/main.leo"
    "pnw_mvp/src/pncw_payroll/leo.toml pnw_mvp/src/pncw_payroll/main.leo"
    "pnw_mvp/src/pniw_payroll/leo.toml pnw_mvp/src/pniw_payroll/main.leo"
)

# Step 2: Deploy Contracts (Using Correct Paths)
echo "🚀 Deploying Contracts in Optimized Order..."
for contract_pair in "${CONTRACTS[@]}"; do
    # Extract the paths from the pair
    leo_toml_path=$(echo "$contract_pair" | cut -d' ' -f1)
    main_leo_path=$(echo "$contract_pair" | cut -d' ' -f2)
    
    dir=$(dirname "$leo_toml_path")  # Get directory name

    echo "🚀 Deploying: $dir"

    # Debugging: Show directory contents before deployment
    echo "🔍 Listing files in $dir:"
    ls -la "$dir"

    # Validate Paths Before Deployment
    if [ ! -f "$leo_toml_path" ]; then
        echo "❌ Error: Missing leo.toml in $dir! (Checked in $(pwd)/$leo_toml_path)"
        exit 248
    fi
    if [ ! -f "$main_leo_path" ]; then
        echo "❌ Error: Missing main.leo in $dir!"
        exit 248
    fi

    # Execute Deployment
    if ! pnw_mvp/directory/.aleo/leo deploy --network $NETWORK --path "$dir" --private-key ${ALEO_PRIVATE_KEY} 2>&1 | tee -a deploy_log.txt; then
        echo "🚨 Deployment failed for $dir!"
        exit 248
    fi
done

echo "✅ PNW-MVP Deployment Complete!"
