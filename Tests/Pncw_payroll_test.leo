import pncw_payroll.leo;
import credits.aleo;
import employer_agreement.leo;
import main.leo;

program pncw_payroll_test.aleo {
    transition test_fund_payroll(employer: address) -> bool {
        let amount: u64 = 1000u64;

        employer_agreement.leo::register_employer(employer);
        employer_agreement.leo::verify_employer_tax(employer);

        let result: bool = pncw_payroll.leo::fund_payroll(employer, amount);
        assert(result);
        return true;
    }

    transition test_execute_payroll(employer: address) -> bool {
        let worker: address = aleo1worker1234567890example;
        let amount: u64 = 100u64;

        main.leo::register_worker(worker, *b"General             ", 0u8); // PNcW
        pncw_payroll.leo::fund_payroll(employer, 1000u64);

        let result: bool = pncw_payroll.leo::execute_payroll(worker, employer, amount);
        assert(result);
        
        let balance: u64 = pncw_payroll.leo::verify_worker_balance(worker);
        assert(balance == amount);
        return true;
    }
}
