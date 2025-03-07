#!/bin/bash

set -e

# Ensure the Aleo private key is set securely
if [[ -z "${ALEO_PRIVATE_KEY}" ]]; then
    echo "🔴 Error: ALEO_PRIVATE_KEY is not set. Please configure it as a repository secret."
    exit 1
fi

# Programs deployment sequence
programs=(
  "credits.leo"
  "employer_agreement.leo"
  "process_tax_compliance.leo"
  "main.leo"
  "subdao_reserve.leo"
  "oversightdao_reserve.leo"
  "pncw_payroll.leo"
  "pniw_payroll.leo"
  "weekly_payroll_pool.leo"
)

echo "🔥 Starting deployment funnel for PNW-MVP..."

cd src  # Move into the src directory where all programs exist

for contract in "${programs[@]}"
do
  echo "🟢 Deploying $contract..."
  leo deploy --network testnet --private-key ${ALEO_PRIVATE_KEY} --path "$contract"
  if [ $? -eq 0 ]; then
      echo "✅ Successfully deployed $contract"
  else
      echo "🔴 Deployment failed for $contract. Stopping deployment pipeline."
      echo "❌ Check the logs above for more details."
      exit 1
  fi
done

cd ..  # Move back to project root after deployment

echo "🎉 All contracts deployed successfully!"
