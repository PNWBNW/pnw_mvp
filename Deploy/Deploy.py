import subprocess

# List of Aleo contracts to deploy
aleo_contracts = {
    "PNcW Payroll": "Contracts/Aleo/Payroll/pncw_payroll.leo",
    "PNiW Payroll": "Contracts/Aleo/Payroll/pniw_payroll.leo",
    "SubDAO AleoUSDC Reserve": "Contracts/Aleo/Fund_pools/subdao_aleo_usdc_reserve.leo",
    "OversightDAO Reserve": "Contracts/Aleo/Fund_pools/oversightdao_combined_reserve.leo",
    "Employer Agreement": "Contracts/Aleo/employer_agreement.leo",
    "Process Tax Compliance": "Contracts/Aleo/Government&taxes/process_tax_compliance.leo",
    "Compliance Tracking": "Contracts/Aleo/Compliance_tracking/compliance_tracking.leo",
    "SubDAO Governance": "Contracts/Aleo/subdao_governance.leo"
}

# List of Aztec contracts to deploy
aztec_contracts = {
    "Aztec Payroll": "Contracts/Aztec/Payroll/aztec_payroll.noir",
    "SubDAO CircleUSDC Reserve": "Contracts/Aztec/Fund_pools/subdao_circle_usdc_reserve.noir"
}

# Function to deploy Aleo contracts
def deploy_aleo_contracts():
    for name, path in aleo_contracts.items():
        print(f"Deploying {name}...")
        result = subprocess.run(["aleo-cli", "deploy", path], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"{name} deployed successfully!\n")
        else:
            print(f"Failed to deploy {name}: {result.stderr}\n")

# Function to deploy Aztec contracts
def deploy_aztec_contracts():
    for name, path in aztec_contracts.items():
        print(f"Deploying {name}...")
        result = subprocess.run(["aztec-cli", "deploy", path], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"{name} deployed successfully!\n")
        else:
            print(f"Failed to deploy {name}: {result.stderr}\n")

if __name__ == "__main__":
    deploy_aleo_contracts()
    deploy_aztec_contracts()
