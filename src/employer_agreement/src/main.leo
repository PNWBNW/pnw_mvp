program employer_agreement.aleo {

mapping agreements: address => EmploymentAgreement;

struct EmploymentAgreement {
    worker: address,
    employer: address,
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
    nonce: scalar
}

async transition create_employment_agreement(
    worker: address,
    employer: address,
    agreed_wage: u64,
    work_hours_per_week: u8,
    pay_period_days: u8,
    raise_schedule_days: u16,
    contract_start_block: u32,
    contract_end_block: u32,
    drug_and_alcohol_policy_signed: bool,
    retirement_option_chosen: u8,
    health_insurance_option_chosen: u8
) -> Future {
    let future: Future = finalize_create_employment_agreement(
        worker,
        employer,
        agreed_wage,
        work_hours_per_week,
        pay_period_days,
        raise_schedule_days,
        contract_start_block,
        contract_end_block,
        drug_and_alcohol_policy_signed,
        retirement_option_chosen,
        health_insurance_option_chosen
    );
    return future;
}

async function finalize_create_employment_agreement(
    worker: address,
    employer: address,
    agreed_wage: u64,
    work_hours_per_week: u8,
    pay_period_days: u8,
    raise_schedule_days: u16,
    contract_start_block: u32,
    contract_end_block: u32,
    drug_and_alcohol_policy_signed: bool,
    retirement_option_chosen: u8,
    health_insurance_option_chosen: u8
) {
    let agreement: EmploymentAgreement = EmploymentAgreement {
        worker,
        employer,
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
        nonce: ChaCha::rand_scalar()
    };

    agreements.set(worker, agreement);
}

async transition terminate_employment_agreement(worker: address) -> Future {
    let future: Future = finalize_terminate_employment_agreement(worker);
    return future;
}

async function finalize_terminate_employment_agreement(worker: address) {
    let mut agreement: EmploymentAgreement = agreements.get(worker);
    agreement.is_active = false;
    agreements.set(worker, agreement);
}

async transition verify_employment_status(worker: address) -> Future {
    let future: Future = finalize_verify_employment_status(worker);
    return future;
}

async function finalize_verify_employment_status(worker: address) {
    assert(agreements.contains(worker));
}
}
