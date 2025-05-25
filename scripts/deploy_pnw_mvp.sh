#!/bin/bash

set -e

echo "🔥 Starting PNW MVP deployment with clean builds and .env toggles..."

ENV_FILE="$DEPLOYMENT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

# Load root-level environment variables
echo "📜 Loading environment variables from $ENV_FILE"
set -a
source "$ENV_FILE"
set +a

PROJECTS=(
    "employer_agreement"
    "oversightdao_reserve"
    "subdao_reserve"
    "pncw_payroll"
    "pniw_payroll"
    "weekly_payroll_pool"
    "process_tax_compliance"
    "payroll_audit_log"
    "ans_registry"
    "employer_registry"
    "worker_profiles"
    "encoder"
)

SRC_ROOT="/home/runner/work/pnw_mvp/pnw_mvp/src"

# Function to clean project artifacts
clean_project() {
    local project_path=$1
    echo "🧹 Cleaning build artifacts for $(basename "$project_path")..."
    
    # Remove build directory
    if [ -d "$project_path/build" ]; then
        rm -rf "$project_path/build"
        echo "  ✅ Removed build/ directory"
    fi
    
    # Remove outputs directory
    if [ -d "$project_path/outputs" ]; then
        rm -rf "$project_path/outputs"
        echo "  ✅ Removed outputs/ directory"
    fi
    
    # Remove .aleo files
    find "$project_path" -name "*.aleo" -type f -delete 2>/dev/null || true
    echo "  ✅ Removed .aleo files"
    
    # Clean any cached Leo files
    if [ -d "$project_path/.leo" ]; then
        rm -rf "$project_path/.leo"
        echo "  ✅ Removed .leo cache"
    fi
}

for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "🚀 Building and deploying: $PROJECT"
        PROJECT_PATH="$SRC_ROOT/$PROJECT"
        if [ -f "$PROJECT_PATH/src/main.leo" ]; then
            cd "$PROJECT_PATH"

            # Clean existing build artifacts
            clean_project "$PROJECT_PATH"

            echo "🔐 Injecting ALEO_PRIVATE_KEY into $PROJECT .env"
            echo "ALEO_PRIVATE_KEY=$ALEO_PRIVATE_KEY" >> .env

            # Clean build before building
            echo "🏗️ Performing clean build for $PROJECT..."
            leo clean || true
            leo build

            echo "📡 Deploying $PROJECT..."
            leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK" --yes

            echo "🧼 Cleaning up ALEO_PRIVATE_KEY"
            sed -i '/^ALEO_PRIVATE_KEY=/d' .env
        else
            echo "❌ main.leo not found at $PROJECT_PATH/src/main.leo"
            exit 1
        fi
    else
        echo "❎ Skipping $PROJECT (toggle is not enabled)"
    fi
done

# Deploy coordinator_program last
echo "🚀 Building and deploying: coordinator_program"
cd "$DEPLOYMENT_ROOT"

# Clean coordinator program artifacts
echo "🧹 Cleaning coordinator_program build artifacts..."
clean_project "$DEPLOYMENT_ROOT"

echo "🔐 Injecting ALEO_PRIVATE_KEY into coordinator .env"
echo "ALEO_PRIVATE_KEY=$ALEO_PRIVATE_KEY" >> .env

# Clean build before building
echo "🏗️ Performing clean build for coordinator_program..."
leo clean || true
leo build

MAX_RETRIES=3
RETRY_DELAY=15

for ((i=1;i<=MAX_RETRIES;i++)); do
    echo "🚀 Attempt $i to deploy coordinator_program..."
    if leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK" --yes; then
        echo "✅ coordinator_program deployed successfully!"
        break
    else
        if [ $i -lt $MAX_RETRIES ]; then
            echo "⚠️ Deployment failed. Retrying in ${RETRY_DELAY} seconds..."
            sleep $RETRY_DELAY
        else
            echo "❌ Deployment failed after $MAX_RETRIES attempts."
            exit 1
        fi
    fi
done

echo "🧼 Cleaning up coordinator .env"
sed -i '/^ALEO_PRIVATE_KEY=/d' .env

echo "✅ All programs deployed successfully with fresh builds!"
echo "📊 New deployment timestamps will appear in your Aleo explorer shortly."
