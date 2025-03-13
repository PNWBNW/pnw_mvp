import credits.aleo;
import subdao_reserve.aleo;
import pncw_payroll.aleo;
import pniw_payroll.aleo;

program weekly_payroll_pool {
    mapping weekly_balance: [u8; 32] => u64;
    mapping worker_types: [u8; 32] => u8;
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

    function lookup_worker_by_ans(worker_ans: [u8; 32]) -> [u8; 32] {
        return worker_ans;
    }
}
