#!/bin/bash

# Ensure Aleo CLI is installed
if ! command -v aleo-cli &> /dev/null
then
    echo "Aleo CLI could not be found. Please install it before running this script."
    exit 1
fi

# Deploy Aleo contracts
echo "Deploying PNcW Payroll Contract..."
aleo-cli deploy Contracts/Aleo/Payroll/pncw_payroll.leo

echo "Deploying PNiW Payroll Contract..."
aleo-cli deploy Contracts/Aleo/Payroll/pniw_payroll.leo

echo "Deploying SubDAO AleoUSDC Reserve..."
aleo-cli deploy Contracts/Aleo/Fund_pools/subdao_aleo_usdc_reserve.leo

echo "Deploying OversightDAO Reserve..."
aleo-cli deploy Contracts/Aleo/Fund_pools/oversightdao_combined_reserve.leo

echo "Deploying Employer Agreement..."
aleo-cli deploy Contracts/Aleo/employer_agreement.leo

echo "Deploying Process Tax Compliance..."
aleo-cli deploy Contracts/Aleo/Government&taxes/process_tax_compliance.leo

echo "Deploying Compliance Tracking..."
aleo-cli deploy Contracts/Aleo/Compliance_tracking/compliance_tracking.leo

echo "Deploying SubDAO Governance..."
aleo-cli deploy Contracts/Aleo/subdao_governance.leo

# Deploy Aztec contracts
echo "Deploying Aztec Payroll Contract..."
aztec-cli deploy Contracts/Aztec/Payroll/aztec_payroll.noir

echo "Deploying SubDAO CircleUSDC Reserve..."
aztec-cli deploy Contracts/Aztec/Fund_pools/subdao_circle_usdc_reserve.noir

echo "Deployment complete!"
