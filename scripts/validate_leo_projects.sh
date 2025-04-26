#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="${1:-src}"

echo "🛠️  Validating all Leo projects under '$ROOT_DIR'..."

for contract_dir in "$ROOT_DIR"/*; do
    if [ -d "$contract_dir" ] && [ -f "$contract_dir/leo.toml" ]; then
        contract_name=$(basename "$contract_dir")
        echo "🧪  Building: $contract_name"
        
        cd "$contract_dir"
        leo build --network testnet || {
            echo "❌  Build failed for $contract_name"
            exit 1
        }
        cd - > /dev/null
    fi
done

echo "✅  All Leo projects built successfully."
