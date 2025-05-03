#!/bin/bash

set -e

echo "🔥 Starting cross-chain deployment with .env toggles..."

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

SRC_ROOT="$PROJECT_ROOT/src"

# Detect deployment tool based on NETWORK
case "$CHAIN" in
    "aleo")
        DEPLOY_TOOL="leo"
        BUILD_CMD="leo build"
        DEPLOY_CMD="leo deploy --private-key \"$ALEO_PRIVATE_KEY\" --network \"$NETWORK\" --yes"
        ;;
    "ethereum")
        DEPLOY_TOOL="hardhat"
        BUILD_CMD="npx hardhat compile"
        DEPLOY_CMD="npx hardhat run --network $NETWORK scripts/deploy.js"
        ;;
    "solana")
        DEPLOY_TOOL="anchor"
        BUILD_CMD="anchor build"
        DEPLOY_CMD="anchor deploy"
        ;;
    *)
        echo "❌ Unsupported chain: $CHAIN"
        exit 1
        ;;
esac

# Deploy each dependency
for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "🚀 Building and deploying: $PROJECT"
        PROJECT_PATH="$SRC_ROOT/$PROJECT"
        if [ -d "$PROJECT_PATH" ]; then
            cd "$PROJECT_PATH"
            eval "$BUILD_CMD"
            eval "$DEPLOY_CMD"
        else
            echo "❌ Project path not found: $PROJECT_PATH"
            exit 1
        fi
    else
        echo "❎ Skipping $PROJECT (toggle is not enabled)"
    fi
done

# Coordinator program deploy
echo "🚀 Deploying coordinator_program"
cd "$DEPLOYMENT_ROOT"
eval "$BUILD_CMD"

MAX_RETRIES=3
RETRY_DELAY=15

for ((i=1;i<=MAX_RETRIES;i++)); do
    echo "🚀 Attempt $i to deploy coordinator_program..."
    if eval "$DEPLOY_CMD"; then
        echo "✅ coordinator_program deployed successfully!"
        break
    else
        if [ $i -lt $MAX_RETRIES ]; then
            echo "⚠️ Retry in ${RETRY_DELAY}s..."
            sleep $RETRY_DELAY
        else
            echo "❌ Final deployment failed."
            exit 1
        fi
    fi
done

echo "✅ All deployments completed!"
