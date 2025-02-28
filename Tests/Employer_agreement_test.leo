import employer_agreement.leo;
import credits.aleo;

program employer_agreement_test.aleo {
    transition test_register_employer() -> bool {
        let employer: address = aleo1employer1234567890example;
        let result: employer_agreement.leo::Employer = employer_agreement.leo::register_employer(employer);
        
        assert(result.employer_address == employer);
        assert(result.registered == true);
        assert(result.tax_compliant == false);
        return true;
    }

    transition test_verify_employer_tax() -> bool {
        let employer: address = aleo1employer1234567890example;
        employer_agreement.leo::register_employer(employer);
        let result: employer_agreement.leo::Employer = employer_agreement.leo::verify_employer_tax(employer);
        
        assert(result.tax_compliant == true);
        assert(result.last_updated > 0u64);
        return true;
    }

    transition test_fund_payroll_pool(subDAO: address) -> bool {
        let employer: address = aleo1employer1234567890example;
        let amount: u64 = 1000u64;

        employer_agreement.leo::register_employer(employer);
        employer_agreement.leo::verify_employer_tax(employer);
        
        // Simulate employer having credits (manual setup needed in practice)
        let result: bool = employer_agreement.leo::fund_payroll_pool(subDAO, amount);
        assert(result);
        return true;
    }
}
