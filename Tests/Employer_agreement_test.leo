import employer_agreement.leo;
import credits.aleo;

program employer_agreement_test.aleo {
    transition test_register_employer() -> bool {
        let employer_ans: [u8; 32] = *b"employer001.pnw.ans";
        let result: employer_agreement.leo::Employer = employer_agreement.leo::register_employer(employer_ans);
        
        assert(result.employer_ans == employer_ans);
        assert(result.registered);
        assert(!result.tax_compliant);
        return true;
    }

    transition test_verify_employer_tax() -> bool {
        let employer_ans: [u8; 32] = *b"employer001.pnw.ans";
        employer_agreement.leo::register_employer(employer_ans);
        let result: employer_agreement.leo::Employer = employer_agreement.leo::verify_employer_tax(employer_ans);
        
        assert(result.tax_compliant);
        assert(result.last_updated > 0u64);
        return true;
    }

    transition test_fund_payroll_pool(subdao_ans: [u8; 32]) -> bool {
        let employer_ans: [u8; 32] = *b"employer001.pnw.ans";
        let amount: u64 = 1000u64;

        employer_agreement.leo::register_employer(employer_ans);
        employer_agreement.leo::verify_employer_tax(employer_ans);
        
        let result: bool = employer_agreement.leo::fund_payroll_pool(subdao_ans, amount);
        assert(result);
        return true;
    }
}
