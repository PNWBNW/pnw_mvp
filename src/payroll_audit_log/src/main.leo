program payroll_audit_log.aleo {

import time_oracle.aleo;

struct DateTime {
    year: u16,
    month: u8,
    day: u8,
    hour: u8,
    minute: u8,
    second: u8
}

mapping payroll_hashes: [u8; 32] => u32;
mapping tax_hashes: [u8; 32] => u32;
mapping payroll_timestamps: [u8; 32] => DateTime;
mapping tax_timestamps: [u8; 32] => DateTime;

async transition record_payroll_hash(hash: [u8; 32]) -> bool {
    let block_height: u32 = time_oracle.aleo/get_block_height();
    payroll_hashes.set(hash, block_height);

    let now: DateTime = get_current_datetime();
    payroll_timestamps.set(hash, now);

    return true;
}

async transition record_tax_hash(hash: [u8; 32]) -> bool {
    let block_height: u32 = time_oracle.aleo/get_block_height();
    tax_hashes.set(hash, block_height);

    let now: DateTime = get_current_datetime();
    tax_timestamps.set(hash, now);

    return true;
}

function get_current_datetime() -> DateTime {
    let dt: DateTime = DateTime {
        year: 2025u16,
        month: 4u8,
        day: 28u8,
        hour: 12u8,
        minute: 0u8,
        second: 0u8
    };
    return dt;
}
