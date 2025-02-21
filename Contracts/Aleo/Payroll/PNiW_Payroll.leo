// PNiW Payroll Contract
program pniw_payroll.aleo;

// Import necessary functions (e.g., from employer agreements or fund pools)
import employer_agreement;
import subdao_aleo_usdc_reserve;

mapping employer_funding: mapping(address, u64); // Employer payroll deposits
mapping worker_balances: mapping(address, u64); // Worker payroll balances

// ✅ Function: Employer funds payroll
function fund_payroll(employer: address, amount: u64) {
    ensure!(amount > 0, "Funding amount must be greater than zero");

    // Verify employer compliance before allowing funding
    ensure!(employer_agreement::is_compliant(employer), "Employer is non-compliant");

    // Add funds to employer payroll balance
    employer_funding[employer] += amount;

    // Deposit into SubDAO AleoUSDC pool
    subdao_aleo_usdc_reserve::deposit(employer, amount);
}

// ✅ Function: Execute payroll for a PNiW worker
function execute_payroll(worker: address, employer: address, amount: u64) {
    ensure!(employer_funding[employer] >= amount, "Insufficient employer funds");

    // Deduct employer's funded payroll balance
    employer_funding[employer] -= amount;

    // Transfer from SubDAO USDC pool to worker
    subdao_aleo_usdc_reserve::transfer(worker, amount);

    // Update worker balance for verification
    worker_balances[worker] += amount;
}

// ✅ Function: Verify worker received payroll
function verify_worker_balance(worker: address) -> u64 {
    return worker_balances[worker];
}
