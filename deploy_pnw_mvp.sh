#!/bin/bash
set -euo pipefail
set -x

echo "🔥 Starting PNW-MVP Deployment Process (using leo add for dependencies)..."
echo "🌍 Using network: $NETWORK"

# Function to extract dependencies from leo.toml
get_dependencies() {
  local toml_file="$1"
  awk '/\[dependencies\]/,/\[/{if(/=/){split($0, a, "="); gsub(/[[:space:]"]/, "", a[1]); print a[1]}}' "$toml_file"
}

for contract_dir in "$DEPLOYMENT_ROOT"/*
do
    if [ -d "$contract_dir" ] && [ -f "$contract_dir/leo.toml" ]; then
        contract=$(basename "$contract_dir")
        echo ""
        echo "🚀 Building: $contract"
        echo "📁 Directory: $contract_dir"

        cd "$contract_dir"

        echo "🔗 Adding local dependencies for $contract..."
        dependencies=$(get_dependencies "leo.toml")
        if [[ -n "$dependencies" ]]; then
            while IFS= read -r dependency; do
                echo "   ➕ Adding local dependency: $dependency"
                if ! leo add --local "../$dependency"; then
                    echo "❌ Failed to add local dependency '$dependency' for $contract"
                    exit 1
                fi
            done <<< "$dependencies"
        else
            echo "   No dependencies found in leo.toml"
        fi

        echo "🛠️ Building $contract..."
        if ! leo build --network "$NETWORK"; then
            echo "❌ Build failed for $contract"
            exit 13
        fi

        echo "✅ Build succeeded for $contract"
        cd .. # Go back to the root of src
    fi
done

echo "🎉 Deployment process completed!"
