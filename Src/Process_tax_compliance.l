import credits.aleo;
import employer_agreement.aleo;
import subDAO_reserve.aleo;

program process_tax_compliance.aleo {
    // Mappings
    mapping employer_tax: address => EmployerTaxRecord;
    mapping employer_zpass_verified: address => bool;
    mapping ans_registry: address => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => address;

    // Constants
    const TAX_SINK: address = aleo1taxsink1234567890example; // Placeholder for Gov API

    // Structs
    struct EmployerTaxRecord {
        employer_address: address,
        total_tax_paid: u64,
        last_payment_timestamp: u64,
        is_compliant: bool
    }

    // Transition: Process tax compliance
    transition process_tax_compliance(employer: address, payroll_type: u8) -> bool {
        assert(employer_zpass_verified[employer]);
        assert(employer_agreement.aleo::employer_registry.contains(employer));

        let mut tax_due: u64 = 0u64;
        if payroll_type == 0u8 { // PNcW
            tax_due = calculate_tax_due(employer, payroll_type);
        } else if payroll_type == 1u8 { // PNiW
            tax_due = calculate_tax_due(employer, payroll_type);
        } else {
            assert(false); // Invalid type
        }

        let employer_record: EmployerTaxRecord = employer_tax[employer];
        let is_compliant: bool = employer_record.total_tax_paid >= tax_due;
        employer_tax[employer] = EmployerTaxRecord {
            employer_address: employer,
            total_tax_paid: employer_record.total_tax_paid,
            last_payment_timestamp: employer_record.last_payment_timestamp,
            is_compliant: is_compliant
        };
        return is_compliant;
    }

    // Transition: Pay taxes
    transition pay_taxes(employer: address, amount: u64) -> bool {
        assert(employer_zpass_verified[employer]);
        assert(amount > 0u64);

        let employer_record: EmployerTaxRecord = employer_tax[employer];
        let new_total: u64 = employer_record.total_tax_paid + amount;

        employer_tax[employer] = EmployerTaxRecord {
            employer_address: employer,
            total_tax_paid: new_total,
            last_payment_timestamp: block.height,
            is_compliant: employer_record.is_compliant // Updated later
        };

        credits.aleo::transfer_public(TAX_SINK, amount);
        subDAO_reserve.aleo::deposit(TAX_SINK, amount); // Track in reserve
        return true;
    }

    // Transition: Register employer ANS
    transition register_employer_ans(employer: address, ans_name: [u8; 32]) -> bool {
        assert(employer_agreement.aleo::employer_registry.contains(employer));
        assert(!ans_reverse_lookup.contains(ans_name));
        ans_registry[employer] = ans_name;
        ans_reverse_lookup[ans_name] = employer;
        return true;
    }

    // Function: Placeholder tax due calculation (replace with real logic later)
    function calculate_tax_due(employer: address, payroll_type: u8) -> u64 {
        // Simulate tax due (e.g., 10% of some payroll total)
        return 100u64; // Placeholder—needs pncw/pniw payroll data
    }

    // Function: Check compliance
    function check_compliance(employer: address) -> bool {
        let employer_record: EmployerTaxRecord = employer_tax[employer];
        return employer_record.is_compliant;
    }

    // Function: Lookup employer by ANS
    function lookup_employer_by_ans(ans_name: [u8; 32]) -> address {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }
}
