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
    "ans_registry"
    "employer_registry"
    "worker_profiles"
)

# Root directory where all src folders live
SRC_ROOT="/home/runner/work/pnw_mvp/pnw_mvp/src"

# Deploy each dependency project using full src path
for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "🚀 Building and deploying: $PROJECT"
        PROJECT_PATH="$SRC_ROOT/$PROJECT"
        if [ -f "$PROJECT_PATH/src/main.leo" ]; then
            cd "$PROJECT_PATH"

            # Safely remove outputs if it exists
            [ -d outputs ] && rm -rf outputs

            leo clean
            leo build
            leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK" --yes
        else
            echo "❌ main.leo not found at $PROJECT_PATH/src/main.leo"
            exit 1
        fi
    else
        echo "❎ Skipping $PROJECT (toggle is not enabled)"
    fi
done

# Deploy coordinator_program (router) last
echo "🚀 Building and deploying: coordinator_program"
cd "$DEPLOYMENT_ROOT"

[ -d outputs ] && rm -rf outputs

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
