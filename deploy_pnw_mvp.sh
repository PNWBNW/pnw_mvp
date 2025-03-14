#!/bin/bash

export PATH=$HOME/.aleo:$PATH
echo "🔥 Deploying Contracts in Optimized Order..."

CONTRACTS=(
  "src/credits"
  "src/employer_agreement"
  "src/process_tax_compliance"
  "src/weekly_payroll_pool"
  "src/subdao_reserve"
  "src/oversightdao_reserve"
  "src/pncw_payroll"
  "src/pniw_payroll"
)

for contract in "${CONTRACTS[@]}"; do
    echo "🚀 Deploying: $contract"
    if [ ! -f "$contract/leo.toml" ]; then
        echo "🚨 leo.toml missing in $contract!"
        exit 248
    fi
    if [ ! -f "$contract/main.leo" ]; then
        echo "🚨 main.leo missing in $contract!"
        exit 248
    fi
    if ! leo deploy --network testnet --path $contract --private-key ${ALEO_PRIVATE_KEY}; then
        echo "🚨 Deployment failed for $contract!"
        exit 248
    fi
done
