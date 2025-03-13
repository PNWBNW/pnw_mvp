import credits.aleo;
import employer_agreement.aleo;
import subdao_reserve.aleo;

program pniw_payroll {
    mapping employer_funding: [u8; 32] => u64;
    mapping worker_balances: [u8; 32] => u64;

    function lookup_worker_by_ans(worker_ans: [u8; 32]) -> [u8; 32] {
        return worker_ans;
    }
}
