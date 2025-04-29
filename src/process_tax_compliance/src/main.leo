program process_tax_compliance.aleo {

import pncw_payroll.aleo;
import pniw_payroll.aleo;
import subdao_reserve.aleo;
import employer_agreement.aleo;
import time_oracle.aleo;

mapping employer_tax: [u8; 32] => EmployerTaxRecord;
mapping employer_zpass_verified: [u8; 32] => bool;
mapping ans_registry: [u8; 32] => [u8; 32];
mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

const TAX_SINK: [u8; 32] = encode_ans(b"govtax.pnw.ans");

struct EmployerTaxRecord {
    employer_ans: [u8; 32],
    total_tax_paid: u32,
    last_payment_block: u32,
    is_compliant: bool
}

async transition process_tax_compliance(employer_ans: [u8; 32], payroll_type: u8) -> bool {
    await verify_compliance(employer_ans);
    await apply_tax_payment(employer_ans, payroll_type);
    return true;
}

async function verify_compliance(employer_ans: [u8; 32]) -> bool {
    let zpass_verified: bool = employer_zpass_verified.get_or_use(employer_ans, false);
    let is_registered: bool = employer_agreement::employer_registry.get_or_use(employer_ans, false);
    assert(zpass_verified && is_registered);
    return true;
}

async function apply_tax_payment(employer_ans: [u8; 32], payroll_type: u8) -> bool {
    let tax_due: u32 = calculate_tax_due(payroll_type);
    let current_block: u32 = time_oracle::current_block_height();

    let current_record: EmployerTaxRecord = employer_tax.get_or_use(employer_ans, EmployerTaxRecord {
        employer_ans,
        total_tax_paid: 0u32,
        last_payment_block: 0u32,
        is_compliant: false
    });

    let updated_total: u32 = current_record.total_tax_paid + tax_due;
    let compliance_status: bool = updated_total >= tax_due;

    employer_tax.set(employer_ans, EmployerTaxRecord {
        employer_ans,
        total_tax_paid: updated_total,
        last_payment_block: current_block,
        is_compliant: compliance_status
    });

    credits::transfer_public(TAX_SINK, tax_due);
    return true;
}

async transition finalize_tax_compliance(employer_ans: [u8; 32]) -> bool {
    let exists: bool = employer_tax.contains(employer_ans);
    assert(exists);
    return true;
}

function calculate_tax_due(payroll_type: u8) -> u32 {
    if payroll_type == 0u8 {
        return 1000u32;
    } else if payroll_type == 1u8 {
        return 500u32;
    } else {
        return 0u32;
    }
}

function encode_ans(ans_name: [u8]) -> [u8; 32] {
    hash_arc721(ans_name)
}
