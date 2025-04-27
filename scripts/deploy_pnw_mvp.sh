#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT_ROOT="${DEPLOYMENT_ROOT:-src}"
DEPLOYMENT_LOGS="${DEPLOYMENT_LOGS:-deploy_logs}"

echo "🔥 Starting deployment script with fresh builds..."
mkdir -p "$DEPLOYMENT_LOGS"

for contract_dir in "$DEPLOYMENT_ROOT"/*; do
    if [ -d "$contract_dir" ] && [ -f "$contract_dir/leo.toml" ]; then
        contract_name=$(basename "$contract_dir")
        
        echo "🚀 Building and deploying: $contract_name"
        cd "$contract_dir"
        
        # Clean previous build artifacts if they exist
        echo "🧹 Cleaning previous build artifacts..."
        leo clean || echo "⚠️ Nothing to clean, skipping."

        # Build the contract fresh
        echo "🔨 Building fresh..."
        leo build --network testnet
        
        # Deploy the contract
        echo "🛫 Deploying..."
        leo deploy --private-key "$ALEO_PRIVATE_KEY" --network testnet
        
        # Save deploy logs if available
        if [[ -f deploy.log ]]; then
            cp deploy.log "$GITHUB_WORKSPACE/$DEPLOYMENT_LOGS/${contract_name}_deploy.log"
        else
            echo "⚠️ No deploy.log found for $contract_name"
        fi
        
        # Return to root
        cd - > /dev/null
    fi
done

echo "✅ All contracts built and deployed cleanly!"
