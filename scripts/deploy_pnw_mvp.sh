#!/bin/bash

set -e

echo "🔥 Starting pnw_router deployment with .env toggles..."

ENV_FILE="$DEPLOYMENT_ROOT/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ .env file not found at $ENV_FILE"
    exit 1
fi

echo "📜 Expanding variables from $ENV_FILE"
envsubst < "$ENV_FILE" > "$DEPLOYMENT_ROOT/.env.expanded"

set -a
source "$DEPLOYMENT_ROOT/.env.expanded"
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
    "employer_registry"
    "worker_profiles"
)

SRC_ROOT="/home/runner/work/pnw_mvp/pnw_mvp/src"
MODULES=()

for PROJECT in "${PROJECTS[@]}"; do
    TOGGLE_VAR="DEPLOY_${PROJECT^^}"
    if [ "${!TOGGLE_VAR}" == "true" ]; then
        echo "✅ Enabled for deploy: $PROJECT"
        MODULES+=("$PROJECT")
    else
        echo "❎ Skipping $PROJECT (toggle not enabled)"
    fi
done

echo "📦 Sending selected modules to repackage.sh: ${MODULES[*]}"
bash "$DEPLOYMENT_ROOT/scripts/repackage.sh" "${MODULES[@]}"

echo "🚀 Building and deploying: pnw_router"
cd "$DEPLOYMENT_ROOT"

leo clean
leo build

echo "📦 Compressing and checksumming build outputs for pnw_router..."
for f in build/*.aleo build/*.wasm; do
    [ -e "$f" ] || continue
    gzip -kf "$f"
    cp "$f.gz" "$DEPLOYMENT_ROOT/outputs/"
    sha256sum "$f.gz" > "$DEPLOYMENT_ROOT/outputs/$(basename "$f").gz.sha256"
    echo "✅ Compressed & checksummed: $(basename "$f")"
done

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

echo "✅ All deployments completed!"
