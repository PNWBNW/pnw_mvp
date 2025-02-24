// Tax Compliance Contract
program process_tax_compliance.leo;

// Import necessary modules
import employer_agreement;
import pncw_payroll;
import pniw_payroll;
import subdao_aleo_native_reserve;

// Constants
const ALEO_NATIVE_TOKEN: address = "aleo1tokenaddress1234567890example"; // Replace with actual Aleo token address

// Mappings
mapping employer_tax: map[address, u64] = {}; // Employer tax compliance records
mapping employer_zpass_verified: map[address, bool] = {}; // Employer ZPass verification status

// ANS Mappings
mapping ans_registry: map[address, string] = {}; // Maps employer addresses to ANS names
mapping ans_reverse_lookup: map[string, address] = {}; // Maps ANS names to employer addresses

// Structs
struct EmployerTaxRecord {
    employer_address: address;
    total_tax_paid: u64;
    last_payment_timestamp: u64;
    is_compliant: bool;
}

// Function: Process tax compliance for PNcW and PNiW payrolls
function process_tax_compliance(employer: address, payroll_type: u8) -> bool {
    assert(employer_zpass_verified.get_or_use(employer, false), "Employer must be ZPass verified for tax compliance");

    let tax_due: u64 = 0;

    // Determine tax obligations based on payroll type
    if payroll_type == 0 {
        tax_due = pncw_payroll::calculate_tax_due(employer);
    } else if payroll_type == 1 {
        tax_due = pniw_payroll::calculate_tax_due(employer);
    } else {
        return false; // Invalid payroll type
    }

    let employer_record = employer_tax.get_or_use(employer, EmployerTaxRecord {
        employer_address: employer,
        total_tax_paid: 0u64,
        last_payment_timestamp: 0u64,
        is_compliant: false,
    });

    // Update compliance status
    employer_record.is_compliant = employer_record.total_tax_paid >= tax_due;
    employer_tax[employer] = employer_record;

    return employer_record.is_compliant;
}

// Function: Process tax compliance using ANS
function process_tax_compliance_by_ans(employer_ans: string, payroll_type: u8) -> bool {
    let employer = lookup_employer_by_ans(employer_ans);
    return process_tax_compliance(employer, payroll_type);
}

// Function: Employers pay taxes
function pay_taxes(employer: address, amount: u64) -> bool {
    assert(employer_zpass_verified.get_or_use(employer, false), "Employer must be ZPass verified to pay taxes");

    let employer_record = employer_tax.get_or_use(employer, EmployerTaxRecord {
        employer_address: employer,
        total_tax_paid: 0u64,
        last_payment_timestamp: 0u64,
        is_compliant: false,
    });

    employer_record.total_tax_paid += amount;
    employer_record.last_payment_timestamp = get_current_time();
    employer_record.is_compliant = process_tax_compliance(employer, 0) || process_tax_compliance(employer, 1);

    employer_tax[employer] = employer_record;
    
    return true;
}

// Function: Employers pay taxes using ANS
function pay_taxes_by_ans(employer_ans: string, amount: u64) -> bool {
    let employer = lookup_employer_by_ans(employer_ans);
    return pay_taxes(employer, amount);
}

// Function: Check employer tax compliance status
function check_compliance(employer: address) -> bool {
    let employer_record = employer_tax.get_or_use(employer, EmployerTaxRecord {
        employer_address: employer,
        total_tax_paid: 0u64,
        last_payment_timestamp: 0u64,
        is_compliant: false,
    });

    return employer_record.is_compliant;
}

// Function: Check employer tax compliance using ANS
function check_compliance_by_ans(employer_ans: string) -> bool {
    let employer = lookup_employer_by_ans(employer_ans);
    return check_compliance(employer);
}

// Function: Lookup an employer's ANS name by address
function lookup_employer_by_address(employer: address) -> string {
    assert(ans_registry.contains(employer), "Employer does not have an ANS name");
    return ans_registry[employer];
}

// Function: Lookup an employer's address by ANS name
function lookup_employer_by_ans(ans_name: string) -> address {
    assert(ans_reverse_lookup.contains(ans_name), "ANS name not found");
    return ans_reverse_lookup[ans_name];
}
