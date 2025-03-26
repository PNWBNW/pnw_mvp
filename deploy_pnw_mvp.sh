#!/bin/bash
set -euo pipefail

# Colors for clarity in output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔥 Starting PNW-MVP Deployment Process...${NC}"

# Load environment variables from .env
if [ -f "$GITHUB_WORKSPACE/.env" ]; then
    set -a
    source "$GITHUB_WORKSPACE/.env"
    set +a
    echo -e "${YELLOW}🌍 Using network: ${NETWORK:-testnet}${NC}"  # Fallback to testnet if unset
else
    echo -e "${RED}❌ Error: .env file not found!${NC}"
    exit 1
fi

# Validate Leo CLI
LEO_CLI="$GITHUB_WORKSPACE/directory/.aleo/leo"
if [ ! -x "$LEO_CLI" ]; then
    echo -e "${RED}❌ Error: Leo CLI not found or not executable at $LEO_CLI!${NC}"
    exit 1
fi

# Ensure we're in the repository root
cd "$GITHUB_WORKSPACE" || {
    echo -e "${RED}❌ Error: Could not enter repository root!${NC}"
    exit 1
}

# Define contract deployment order
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

echo -e "${GREEN}🚀 Deploying Contracts in Optimized Order...${NC}"
for contract_dir in "${CONTRACTS[@]}"; do
    echo -e "${YELLOW}🚀 Deploying: $contract_dir${NC}"

    # Show files in folder
    echo -e "${YELLOW}🔍 Listing files in $contract_dir:${NC}"
    ls -la "$contract_dir" || {
        echo -e "${RED}⚠️ Warning: $contract_dir does not exist!${NC}"
        continue
    }

    # Validate files
    if [ ! -f "$contract_dir/leo.toml" ]; then
        echo -e "${RED}❌ Error: Missing leo.toml in $contract_dir!${NC}"
        exit 248
    fi
    if [ ! -f "$contract_dir/main.leo" ]; then
        echo -e "${RED}❌ Error: Missing main.leo in $contract_dir!${NC}"
        exit 248
    fi

    # Deploy the contract
    if ! "$LEO_CLI" deploy --network "${NETWORK:-testnet}" --path "$contract_dir" --private-key "${ALEO_PRIVATE_KEY}" 2>&1 | tee -a deploy_log.txt; then
        echo -e "${RED}🚨 Deployment failed for $contract_dir!${NC}"
        exit 248
    fi
done

echo -e "${GREEN}✅ PNW-MVP Deployment Complete!${NC}"
