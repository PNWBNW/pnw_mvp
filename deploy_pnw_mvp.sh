#!/bin/bash
set -euo pipefail
set -x

echo "🔥 Starting PNW-MVP Deployment Process (using leo add for dependencies)..."
echo "🌍 Using network: $NETWORK"

# Function to extract local dependencies with their paths from leo.toml
get_local_dependencies() {
  local toml_file="$1"
  awk "/\\[dependencies\\]/,/\\[/{if(/path *=/){split(\$0, a, \"=\"); gsub(/[[:space:]\\\"'\\{\\}]/, \"\", a[2]); print a[2]}}/" "$toml_file"
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
        local_dependencies=$(get_local_dependencies "leo.toml")
        if [[ -n "$local_dependencies" ]]; then
            while IFS= read -r dependency_path; do
                echo "   ➕ Adding local dependency: $dependency_path"
                if ! leo add --path "$dependency_path"; then
                    echo "❌ Failed to add local dependency '$dependency_path' for $contract"
                    exit 1
                fi
            done <<< "$local_dependencies"
        else
            echo "   No local dependencies found in leo.toml"
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
