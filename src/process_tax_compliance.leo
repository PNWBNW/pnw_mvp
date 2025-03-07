import credits.leo;
import employer_agreement.leo;
import subDAO_reserve.leo;

program process_tax_compliance.leo {
    mapping employer_tax: [u8; 32] => EmployerTaxRecord;
    mapping employer_zpass_verified: [u8; 32] => bool;
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

    const TAX_SINK: [u8; 32] = *b"govtax.pnw.ans";

    struct EmployerTaxRecord {
        employer_ans: [u8; 32],
        total_tax_paid: u64,
        last_payment_timestamp: u64,
        is_compliant: bool
    }

    async transition process_tax_compliance(employer_ans: [u8; 32], payroll_type: u8) -> (bool, async transition) {
        assert(employer_zpass_verified[employer_ans]);
        assert(employer_agreement.leo::employer_registry.contains(employer_ans));

        let mut tax_due: u64 = 0u64;
        if payroll_type == 0u8 {
            tax_due = calculate_tax_due(employer_ans, payroll_type);
        } else if payroll_type == 1u8 {
            tax_due = calculate_tax_due(employer_ans, payroll_type);
        } else {
            assert(false);
        }

        let employer_record: EmployerTaxRecord = employer_tax[employer_ans];
        let is_compliant: bool = employer_record.total_tax_paid >= tax_due;
        Mapping::set(employer_tax, employer_ans, EmployerTaxRecord {
            employer_ans,
            total_tax_paid: employer_record.total_tax_paid,
            last_payment_timestamp: employer_record.last_payment_timestamp,
            is_compliant
        });

        return (is_compliant, process_tax_compliance);
    }

    async transition pay_taxes(employer_ans: [u8; 32], amount: u64) -> (bool, async transition) {
        assert(employer_zpass_verified[employer_ans]);
        assert(amount > 0u64);

        let employer_record: EmployerTaxRecord = employer_tax[employer_ans];
        let new_total: u64 = employer_record.total_tax_paid.checked_add(amount);

        Mapping::set(employer_tax, employer_ans, EmployerTaxRecord {
            employer_ans,
            total_tax_paid: new_total,
            last_payment_timestamp: block.height,
            is_compliant: employer_record.is_compliant
        });

        credits.leo::transfer_public(TAX_SINK, amount);
        subdao_reserve.leo::deposit(TAX_SINK, amount);

        return (true, pay_taxes);
    }

    async transition register_employer_ans(employer_ans: [u8; 32], ans_name: [u8; 32]) -> (bool, async transition) {
        assert(employer_agreement.leo::employer_registry.contains(employer_ans));
        assert(!ans_reverse_lookup.contains(ans_name));

        Mapping::set(ans_registry, employer_ans, ans_name);
        Mapping::set(ans_reverse_lookup, ans_name, employer_ans);

        return (true, register_employer_ans);
    }

    function calculate_tax_due(employer_ans: [u8; 32], payroll_type: u8) -> u64 {
        return 100u64;
    }

    function check_compliance(employer_ans: [u8; 32]) -> bool {
        let employer_record: EmployerTaxRecord = employer_tax[employer_ans];
        return employer_record.is_compliant;
    }

    function lookup_employer_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }
}
