import process_tax_compliance.leo;
import credits.leo;

program process_tax_compliance_test.leo {
    transition test_pay_taxes(employer_ans: [u8; 32]) -> bool {
        let amount: u64 = 100u64;

        let (_, _) = process_tax_compliance.leo::pay_taxes(employer_ans, amount);
        
        let record: process_tax_compliance.leo::EmployerTaxRecord = process_tax_compliance.leo::employer_tax[employer_ans];
        assert(record.total_tax_paid == amount);
        assert(record.last_payment_timestamp > 0u64);
        return true;
    }

    transition test_process_tax_compliance(employer_ans: [u8; 32]) -> bool {
        let payroll_type: u8 = 0u8; 
        
        let (result, _) = process_tax_compliance.leo::process_tax_compliance(employer_ans, payroll_type);
        assert(result);
        return true;
    }
}
