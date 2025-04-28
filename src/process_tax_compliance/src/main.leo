program process_tax_compliance {

import pncw_payroll.aleo;
import pniw_payroll.aleo;
import subdao_reserve.aleo;
import employer_agreement.aleo;

mapping employer_tax: [u8; 32] => EmployerTaxRecord;
mapping employer_zpass_verified: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

const TAX_SINK: [u8; 32] = encode_ans(b"govtax.pnw.ans");

struct EmployerTaxRecord {
    employer_ans: [u8; 32],
    total_tax_paid: u32,
    last_payment_timestamp: u32,
    is_compliant: bool
}

function encode_ans(ans_name: [u8]) -> [u8; 32] {
    hash_arc721(ans_name)
}

function calculate_tax_due(payroll_type: u8) -> u32 {
    if payroll_type == 0u8 {
        1000u32
    } else if payroll_type == 1u8 {
        500u32
    } else {
        0u32
    }
}

async transition process_tax_compliance(employer_ans: [u8; 32], payroll_type: u8) -> bool {
    assert(employer_zpass_verified.get_or_use(employer_ans, false));
    assert(employer_agreement::employer_registry.get_or_use(employer_ans, false));

    let tax_due: u32 = calculate_tax_due(payroll_type);

    let employer_record: EmployerTaxRecord = employer_tax.get_or_use(employer_ans, EmployerTaxRecord {
        employer_ans,
        total_tax_paid: 0u32,
        last_payment_timestamp: 0u32,
        is_compliant: false
    });

    let is_compliant: bool = employer_record.total_tax_paid >= tax_due;

    employer_tax.set(employer_ans, EmployerTaxRecord {
        employer_ans,
        total_tax_paid: employer_record.total_tax_paid + tax_due,
        last_payment_timestamp: block.timestamp,
        is_compliant
    });

    if !is_compliant {
        credits::transfer_public(TAX_SINK, tax_due);
    }

    return true;
}

async transition finalize_tax_compliance(employer_ans: [u8; 32]) -> bool {
    assert(employer_tax.contains(employer_ans));
    return true;
}
