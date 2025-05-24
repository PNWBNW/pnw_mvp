#!/bin/bash

set -e

echo "🔥 Starting PNW MVP deployment with .env toggles..."

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
ENCODER_SOURCE="$SRC_ROOT/encoder/src/main.leo"

for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "🚀 Building and deploying: $PROJECT"
        PROJECT_PATH="$SRC_ROOT/$PROJECT"
        if [ -f "$PROJECT_PATH/src/main.leo" ]; then
            cd "$PROJECT_PATH"

            echo "🔐 Injecting ALEO_PRIVATE_KEY into $PROJECT .env"
            echo "ALEO_PRIVATE_KEY=$ALEO_PRIVATE_KEY" >> .env

            if [ "$PROJECT" != "encoder" ]; then
                echo "📦 Copying encoder/src/main.leo → $PROJECT/src/encoder.leo"
                cp "$ENCODER_SOURCE" "$PROJECT_PATH/src/encoder.leo"
            fi

            leo build
            leo deploy --private-key "$ALEO_PRIVATE_KEY" --network "$NETWORK" --yes

            if [ "$PROJECT" != "encoder" ]; then
                echo "🧼 Cleaning up encoder.leo and ALEO_PRIVATE_KEY"
                rm -f "$PROJECT_PATH/src/encoder.leo"
            else
                echo "🧼 Cleaning up ALEO_PRIVATE_KEY"
            fi
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

echo "🔐 Injecting ALEO_PRIVATE_KEY into coordinator .env"
echo "ALEO_PRIVATE_KEY=$ALEO_PRIVATE_KEY" >> .env

echo "📦 Copying encoder/src/main.leo → coordinator_program/src/encoder.leo"
cp "$ENCODER_SOURCE" "$DEPLOYMENT_ROOT/src/encoder.leo"

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

echo "🧼 Cleaning up coordinator .env and encoder.leo"
rm -f "$DEPLOYMENT_ROOT/src/encoder.leo"
sed -i '/^ALEO_PRIVATE_KEY=/d' .env

echo "✅ All programs deployed successfully!"completed!"
