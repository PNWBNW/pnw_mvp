import credits.aleo;
import weekly_payroll_pool.aleo;
import process_tax_compliance.aleo;

program subdao_reserve {
    mapping reserve_balance: [u8; 32] => u64;
    mapping tax_obligations: [u8; 32] => u64;

    const TAX_RATE: u64 = 10u64;
}
