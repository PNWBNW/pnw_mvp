#!/bin/bash

set -e

echo "🔥 Starting pnw_router deployment with .env toggles..."

ENV_FILE="$DEPLOYMENT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

# Use envsubst to expand GitHub secrets into a temporary env file
echo "📜 Expanding variables from $ENV_FILE"
envsubst < "$ENV_FILE" > "$DEPLOYMENT_ROOT/.env.expanded"

# Load expanded environment variables
set -a
source "$DEPLOYMENT_ROOT/.env.expanded"
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
    "employer_registry"
    "worker_profiles"
)

SRC_ROOT="/home/runner/work/pnw_mvp/pnw_mvp/src"

# Deploy dependency contracts
for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "🚀 Building and deploying: $PROJECT"
        PROJECT_PATH="$SRC_ROOT/$PROJECT"
        if [ -f "$PROJECT_PATH/src/main.leo" ]; then
            cd "$PROJECT_PATH"
            leo clean
            leo build
            leo deploy --private-key "$PRIVATE_KEY" --network "$NETWORK" --yes
        else
            echo "❌ main.leo not found at $PROJECT_PATH/src/main.leo"
            exit 1
        fi
    else
        echo "❎ Skipping $PROJECT (toggle is not enabled)"
    fi
done

# Deploy final program (pnw_router)
echo "🚀 Building and deploying: pnw_router"
cd "$DEPLOYMENT_ROOT"

leo clean
leo build

MAX_RETRIES=3
RETRY_DELAY=15

for ((i=1;i<=MAX_RETRIES;i++)); do
    echo "🚀 Attempt $i to deploy pnw_router..."
    if leo deploy --private-key "$PRIVATE_KEY" --network "$NETWORK" --yes; then
        echo "✅ pnw_router deployed successfully!"
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
