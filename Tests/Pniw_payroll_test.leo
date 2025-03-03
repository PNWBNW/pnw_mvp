import pniw_payroll.leo;
import credits.aleo;
import employer_agreement.leo;
import main.leo;

program pniw_payroll_test.aleo {
    transition test_fund_payroll(employer_ans: [u8; 32]) -> bool {
        let amount: u64 = 1000u64;

        employer_agreement.leo::register_employer(employer_ans);
        employer_agreement.leo::verify_employer_tax(employer_ans);

        let result: bool = pniw_payroll.leo::fund_payroll(employer_ans, amount);
        assert(result);
        return true;
    }

    transition test_execute_payroll(employer_ans: [u8; 32]) -> bool {
        let worker_ans: [u8; 32] = *b"worker001.pniw.ans";
        let amount: u64 = 100u64;

        main.leo::register_worker(worker_ans, 0u8, 1u8, *b"ZPassHashPlaceholder");
        pniw_payroll.leo::fund_payroll(employer_ans, 1000u64);

        let result: bool = pniw_payroll.leo::execute_payroll(worker_ans, employer_ans, amount);
        assert(result);
        
        let balance: u64 = pniw_payroll.leo::verify_worker_balance(worker_ans);
        assert(balance == amount);
        return true;
    }
}
