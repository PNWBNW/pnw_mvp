import pncw_payroll.leo;
import credits.aleo;
import employer_agreement.leo;
import main.leo;

program pncw_payroll_test.aleo {
    transition test_fund_payroll(employer_ans: [u8; 32]) -> bool {
        let amount: u64 = 1000u64;

        let (_, _) = employer_agreement.leo::register_employer(employer_ans);
        let (_, _) = employer_agreement.leo::verify_employer_tax(employer_ans);

        let (result, _) = pncw_payroll.leo::fund_payroll(employer_ans, amount);
        assert(result);
        return true;
    }

    transition test_execute_payroll(employer_ans: [u8; 32]) -> bool {
        let worker_ans: [u8; 32] = *b"worker001.pncw.ans";
        let amount: u64 = 100u64;
        let zpass_hash: [u8; 64] = *b"ZPassHashPlaceholder";

        let (_, _) = main.leo::register_worker(worker_ans, 0u8, 0u8, zpass_hash);
        let (_, _) = pncw_payroll.leo::fund_payroll(employer_ans, 1000u64);

        let (result, _) = pncw_payroll.leo::execute_payroll(worker_ans, employer_ans, amount);
        assert(result);
        
        let balance: u64 = pncw_payroll.leo::verify_worker_balance(worker_ans);
        assert(balance == amount);
        return true;
    }
}
