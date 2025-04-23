#!/bin/bash
set -euo pipefail
set -x

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"

for contract_dir in "$DEPLOYMENT_ROOT"/*; do
    if [ -d "$contract_dir" ] && [ -f "$contract_dir/leo.toml" ]; then
        contract=$(basename "$contract_dir")
        echo ""
        echo "🚀 Building: $contract"
        echo "📁 Directory: $contract_dir"
        
        cd "$contract_dir"

        if ! leo build --network "$NETWORK" .; then
            echo "❌ Build failed for $contract at $contract_dir"
            exit 13
        fi

        echo "✅ Build succeeded for $contract"
    fi
done

echo "🎉 All contracts built successfully!"
