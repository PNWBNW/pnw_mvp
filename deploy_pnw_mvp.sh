#!/bin/bash
set -e

echo "🔥 Starting PNW-MVP Deployment Process..."
echo "🌍 Using network: $NETWORK"
echo ""

echo "🔎 Validating and Deploying contracts in: $DEPLOYMENT_ROOT"
echo ""

for project_dir in "$DEPLOYMENT_ROOT"/*; do
    if [ -d "$project_dir" ]; then
        contract_name=$(basename "$project_dir")
        echo "🚀 Building: $contract_name"
        echo "📁 Directory: $project_dir"

        # Write .env for Leo if not already present
        echo "NETWORK=$NETWORK" > "$project_dir/.env"

        # Ensure imports and build directories exist
        mkdir -p "$project_dir/import"
        mkdir -p "$project_dir/build"

        # Build with --network explicitly
        log_file="$DEPLOYMENT_LOGS/${contract_name}_log.txt"
        (
            cd "$project_dir"
            leo build --network "$NETWORK"
        ) > "$log_file" 2>&1

        if grep -q "Build succeeded" "$log_file"; then
            echo "✅ Build succeeded for $contract_name"
        else
            echo "❌ Build failed for $contract_name"
            echo "📄 See log: $log_file"
        fi

        echo ""
    fi
done

echo "✅ Deployment process finished."
