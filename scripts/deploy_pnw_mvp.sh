#!/usr/bin/env bash
set -euo pipefail

DEPLOYMENT_ROOT="${DEPLOYMENT_ROOT:-src}"
DEPLOYMENT_LOGS="${DEPLOYMENT_LOGS:-deploy_logs}"

echo "🔥 Starting deployment script..."
mkdir -p "$DEPLOYMENT_LOGS"

for contract_dir in "$DEPLOYMENT_ROOT"/*; do
    if [ -d "$contract_dir" ] && [ -f "$contract_dir/leo.toml" ]; then
        contract_name=$(basename "$contract_dir")
        
        echo "🚀 Deploying: $contract_name"
        cd "$contract_dir"
        
        # Build again before deploy to be safe
        leo build --network testnet
        
        # Deploy
        leo deploy --private-key "$ALEO_PRIVATE_KEY" --network testnet
        
        # Save logs
        cp deploy.log "$GITHUB_WORKSPACE/$DEPLOYMENT_LOGS/${contract_name}_deploy.log" || echo "⚠️  No deploy.log for $contract_name"
        
        cd - > /dev/null
    fi
done

echo "✅ Deployment complete!"
