program employer_agreement.aleo;

import aleo_gas_station.aleo;
import stellar_gas_station.aleo;

mapping agreements: field => EmploymentAgreement;

struct CredentialKey {
    worker: address,
    subdao_id: u16,
    employer_hash: field
}

struct EmploymentAgreement {
    worker: address,
    employer: address,
    employer_hash: field,
    subdao_id: u16,
    agreed_wage: u64,
    work_hours_per_week: u8,
    pay_period_days: u8,
    raise_schedule_days: u16,
    contract_start_block: u32,
    contract_end_block: u32,
    drug_and_alcohol_policy_signed: bool,
    retirement_option_chosen: u8,
    health_insurance_option_chosen: u8,
    is_active: bool,
    nonce: u64
}

inline function hash_credential_key(key: CredentialKey) -> field {
    Poseidon2::hash([
        key.worker,
        key.subdao_id as u128,
        key.employer_hash
    ])
}

async transition create_agreement(
    worker: address,
    employer: address,
    employer_hash: field,
    subdao_id: u16,
    agreed_wage: u64,
    work_hours_per_week: u8,
    pay_period_days: u8,
    raise_schedule_days: u16,
    contract_start_block: u32,
    contract_end_block: u32,
    drug_and_alcohol_policy_signed: bool,
    retirement_option_chosen: u8,
    health_insurance_option_chosen: u8,
    nonce: u64
) -> Future {
    let future: Future = finalize_create_agreement(
        worker,
        employer,
        employer_hash,
        subdao_id,
        agreed_wage,
        work_hours_per_week,
        pay_period_days,
        raise_schedule_days,
        contract_start_block,
        contract_end_block,
        drug_and_alcohol_policy_signed,
        retirement_option_chosen,
        health_insurance_option_chosen,
        nonce
    );
    return future;
}

async function finalize_create_agreement(
    worker: address,
    employer: address,
    employer_hash: field,
    subdao_id: u16,
    agreed_wage: u64,
    work_hours_per_week: u8,
    pay_period_days: u8,
    raise_schedule_days: u16,
    contract_start_block: u32,
    contract_end_block: u32,
    drug_and_alcohol_policy_signed: bool,
    retirement_option_chosen: u8,
    health_insurance_option_chosen: u8,
    nonce: u64
) {
    // Compute required amounts
    let wage_required: u64 = agreed_wage * pay_period_days as u64;
    let gas_required: u64 = 10_000u64; // Future logic may customize by DAO or worker tier

    // Prefunding checks
    let gas_future: Future = aleo_gas_station.aleo/check_gas_pool(subdao_id, employer, gas_required);
    await gas_future;

    let wage_future: Future = stellar_gas_station.aleo/check_wage_pool(subdao_id, employer, wage_required);
    await wage_future;

    // Build record
    let agreement: EmploymentAgreement = EmploymentAgreement {
        worker,
        employer,
        employer_hash,
        subdao_id,
        agreed_wage,
        work_hours_per_week,
        pay_period_days,
        raise_schedule_days,
        contract_start_block,
        contract_end_block,
        drug_and_alcohol_policy_signed,
        retirement_option_chosen,
        health_insurance_option_chosen,
        is_active: true,
        nonce
    };

    let key: CredentialKey = CredentialKey {
        worker,
        subdao_id,
        employer_hash
    };

    let hash: field = hash_credential_key(key);
    agreements.set(hash, agreement);
}

async transition terminate_agreement(
    worker: address,
    employer_hash: field,
    subdao_id: u16
) -> Future {
    let key: CredentialKey = CredentialKey {
        worker,
        subdao_id,
        employer_hash
    };

    let hash: field = hash_credential_key(key);
    let original: EmploymentAgreement = agreements.get(hash);

    let terminated: EmploymentAgreement = EmploymentAgreement {
        worker: original.worker,
        employer: original.employer,
        employer_hash: original.employer_hash,
        subdao_id: original.subdao_id,
        agreed_wage: original.agreed_wage,
        work_hours_per_week: original.work_hours_per_week,
        pay_period_days: original.pay_period_days,
        raise_schedule_days: original.raise_schedule_days,
        contract_start_block: original.contract_start_block,
        contract_end_block: original.contract_end_block,
        drug_and_alcohol_policy_signed: original.drug_and_alcohol_policy_signed,
        retirement_option_chosen: original.retirement_option_chosen,
        health_insurance_option_chosen: original.health_insurance_option_chosen,
        is_active: false,
        nonce: original.nonce
    };

    agreements.set(hash, terminated);
}

async transition verify_agreement(
    worker: address,
    employer_hash: field,
    subdao_id: u16
) -> Future {
    let key: CredentialKey = CredentialKey {
        worker,
        subdao_id,
        employer_hash
    };

    let hash: field = hash_credential_key(key);
    let future: Future = finalize_verify(hash);
    return future;
}

async function finalize_verify(hash: field) {
    assert(agreements.contains(hash));
}
