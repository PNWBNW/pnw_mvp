# PNW-MVP: Payroll Infrastructure

A zero-knowledge payroll system on Aleo testnet, built with Leo 2.4.1.

## Contracts
- `employer_agreement.aleo`: Employer funding entry point.
- `oversightDAO_reserve.aleo`: 17% backup/investment pool (ANS: `oversightdao.pnw.ans`).
- `subDAO_reserve.aleo`: SubDAO payroll and tax management.
- `weekly_payroll_pool.aleo`: Weekly worker payouts.
- `main.leo`: Core orchestration.

## Setup
1. Install Leo CLI: `curl -sSL https://install.aleo.org | bash`
2. Clone repo: `git clone <repo-url>`
3. Build: `leo build`

## Testing
- Run tests: `leo run test_<transition>` (e.g., `leo run main_test.test_register_worker`)
- See `tests/` directory.

## Deployment
- Local: `leo deploy --network testnet --private-key <your-test-key>`
- GitHub Actions: Uses `Aleo_test_key` secret (see `.github/workflows/deploy.yml`).
  1. Add your test private key to GitHub Secrets as `Aleo_test_key`.
  2. Push to `main` to trigger deployment.

## Flow
1. Fund: `leo run fund_payroll_pool aleo1subdao... 1000u64`
2. Taxes: `leo run process_taxes aleo1subdao...`
3. Payroll: `leo run fund_weekly_pool aleo1subdao... 700u64`, then `leo run pay_worker aleo1worker... aleo1subdao... 100u64`
