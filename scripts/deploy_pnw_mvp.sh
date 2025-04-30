#!/bin/bash

set -e

echo "🔥 Starting coordinator program deployment with .env toggles..."

ENV_FILE="$DEPLOYMENT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

# Load environment variables
echo "📜 Loading environment variables from $ENV_FILE"
set -a
source "$ENV_FILE"
set +a

# Set project root absolute path
ROOT_DIR="$(dirname "$DEPLOYMENT_ROOT")"

# List of dependency projects
PROJECTS=(
    "employer_agreement"
    "oversightdao_reserve"
    "subdao_reserve"
    "pncw_payroll"
    "pniw_payroll"
    "weekly_payroll_pool"
    "process_tax_compliance"
    "payroll_audit_log"
)

# Deploy each dependency project
for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "🚀 Building and deploying: $PROJECT"
        PROJECT_PATH="$ROOT_DIR/$PROJECT"
        if [ -d "$PROJECT_PATH" ]; then
            cd "$PROJECT_PATH"
            leo clean
            leo build
            leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK" --yes
        else
            echo "❌ Directory not found for $PROJECT at $PROJECT_PATH"
            exit 1
        fi
    else
        echo "❎ Skipping $PROJECT (toggle is not enabled)"
    fi
done

# Deploy the coordinator_program
echo "🚀 Building and deploying: coordinator_program"
cd "$DEPLOYMENT_ROOT"
leo clean
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

echo "✅ Deployment completed!"
