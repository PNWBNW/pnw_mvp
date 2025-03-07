#!/bin/bash

set -e

# Ensure the Aleo private key is set securely
if [[ -z "${ALEO_PRIVATE_KEY}" ]]; then
    echo "🔴 Error: ALEO_PRIVATE_KEY is not set. Please configure it as a repository secret."
    exit 1
fi

# Programs deployment sequence
programs=(
  "credits"
  "employer_agreement"
  "process_tax_compliance"
  "main"
  "subdao_reserve"
  "oversightdao_reserve"
  "pncw_payroll"
  "pniw_payroll"
  "weekly_payroll_pool"
)

echo "🔥 Starting deployment funnel for PNW-MVP..."

for contract in "${programs[@]}"
do
  echo "🟢 Deploying $contract..."
  cd src/$contract
  leo deploy --network testnet --private-key ${ALEO_PRIVATE_KEY}
  cd - > /dev/null  # Move back to project root silently
  if [ $? -eq 0 ]; then
      echo "✅ Successfully deployed $contract"
  else
      echo "🔴 Deployment failed for $contract. Stopping deployment pipeline."
      echo "❌ Check the logs above for more details."
      exit 1
  fi
done

echo "🎉 All contracts deployed successfully!"
