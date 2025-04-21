#!/bin/bash

echo "🔥 Starting PNW-MVP Deployment Process..."

# Validate environment
if [ -z "$DEPLOYMENT_ROOT" ] || [ -z "$DEPLOYMENT_LOGS" ]; then
  echo "❌ Environment variables DEPLOYMENT_ROOT or DEPLOYMENT_LOGS not set!"
  exit 1
fi

echo "🌍 Using network: ${NETWORK:-testnet}"
mkdir -p "$DEPLOYMENT_LOGS"

# List of contract directories (in optimized order)
CONTRACTS=(
  "employer_agreement"
  "process_tax_compliance"
  "weekly_payroll_pool"
  "subdao_reserve"
  "oversightdao_reserve"
  "pncw_payroll"
  "pniw_payroll"
)

echo "🚀 Deploying Contracts in Optimized Order..."

for CONTRACT in "${CONTRACTS[@]}"; do
  CONTRACT_PATH="$DEPLOYMENT_ROOT/$CONTRACT"
  LOG_PATH="$DEPLOYMENT_LOGS/${CONTRACT}_deploy.log"

  echo "🚀 Deploying: $CONTRACT"
  echo "🔍 Listing files in $CONTRACT_PATH:"
  ls -la "$CONTRACT_PATH"

  if [ ! -f "$CONTRACT_PATH/leo.toml" ]; then
    echo "❌ Error: Missing leo.toml in $CONTRACT_PATH!" | tee -a "$LOG_PATH"
    continue
  fi

  if [ ! -f "$CONTRACT_PATH/main.leo" ]; then
    echo "❌ Error: Missing main.leo in $CONTRACT_PATH!" | tee -a "$LOG_PATH"
    continue
  fi

  # Deploy contract and log output
  if ! leo deploy --path "$CONTRACT_PATH" --network "${NETWORK:-testnet}" --private-key "$ALEO_PRIVATE_KEY" 2>&1 | tee "$LOG_PATH"; then
    echo "🚨 Deployment failed for $CONTRACT!"
  else
    echo "✅ Successfully deployed: $CONTRACT"
  fi
done

echo "✅ All deployments completed."
