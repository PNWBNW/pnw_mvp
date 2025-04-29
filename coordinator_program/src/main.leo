program parent_main.aleo {

import pncw_payroll.aleo;
import pniw_payroll.aleo;
import employer_agreement.aleo;
import process_tax_compliance.aleo;
import payroll_audit_log.aleo;
import time_oracle.aleo;

struct DateTime {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8
}

// ========== FUNCTION SECTION (local/private) ==========

function calculate_worker_payment(worker_id: [u8; 32]) -> u64 {
    pncw_payroll/get_payment_amount(worker_id)
};

function calculate_noncitizen_payment(worker_id: [u8; 32]) -> u64 {
    pniw_payroll/get_payment_amount(worker_id)
};

function lookup_employer_ans(ans_name: [u8; 32]) -> [u8; 32] {
    employer_agreement/lookup_employer_by_ans(ans_name)
};

function check_tax_compliance(employer_id: [u8; 32]) -> bool {
    process_tax_compliance/check_tax_status(employer_id)
};

function audit_payment_hash(payment_hash: [u8; 32]) -> bool {
    payroll_audit_log/check_payment(payment_hash)
};

function audit_tax_hash(tax_hash: [u8; 32]) -> bool {
    payroll_audit_log/check_tax(tax_hash)
};

function get_current_block_height() -> u32 {
    time_oracle/get_block_height()
};

// ========== TRANSITION SECTION (for on-chain changes) ==========

async transition pay_pncw(worker_id: [u8; 32], amount: u64) -> bool {
    pncw_payroll/pay_worker(worker_id, amount)
};

async transition pay_pniw(worker_id: [u8; 32], amount: u64) -> bool {
    pniw_payroll/pay_worker(worker_id, amount)
};

async transition verify_employer_tax(employer_id: [u8; 32]) -> bool {
    process_tax_compliance/verify_employer(employer_id)
};

async transition finalize_payment_audit(payment_hash: [u8; 32], block_height: u32) -> bool {
    payroll_audit_log/log_payment(payment_hash, block_height)
};

async transition finalize_tax_audit(tax_hash: [u8; 32], block_height: u32) -> bool {
    payroll_audit_log/log_tax(tax_hash, block_height)
};

}
