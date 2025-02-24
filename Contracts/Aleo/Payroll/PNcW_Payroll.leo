// PNcW Payroll Contract
program pncw_payroll.leo;

// Import necessary functions (e.g., from employer agreements or fund pools)
import employer_agreement;
import subdao_aleo_usdc_reserve;

// Mappings
mapping employer_funding: map[address, u64] = {}; // Tracks employer funds for payroll
mapping worker_balances: map[address, u64] = {}; // Worker payroll balances

//  Function: Employer funds payroll
function fund_payroll(employer: address, amount: u64) -> bool {
    assert(amount > 0, "Funding amount must be greater than zero");

    // Verify employer compliance before allowing funding
    assert(employer_agreement::is_compliant(employer), "Employer is non-compliant");

    // Add funds to employer payroll balance
    employer_funding[employer] += amount;

    // Deposit into SubDAO AleoUSDC pool
    subdao_aleo_usdc_reserve::deposit(employer, amount);
    
    return true;
}

//  Function: Execute payroll for a worker
function execute_payroll(worker: address, employer: address, amount: u64) -> bool {
    assert(employer_funding.get(employer).unwrap_or(0) >= amount, "Insufficient employer funds");

    // Deduct employer's funded payroll balance
    employer_funding[employer] -= amount;

    // Transfer from SubDAO USDC pool to worker
    subdao_aleo_usdc_reserve::transfer(worker, amount);

    // Update worker balance for verification
    worker_balances[worker] += amount;
    
    return true;
}

//  Function: Verify worker received payroll
function verify_worker_balance(worker: address) -> u64 {
    return worker_balances.get(worker).unwrap_or(0);
}
