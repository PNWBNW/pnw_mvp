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
        nonce: u64
    }

    async transition create_agreement(
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
        nonce: u64
    ) -> Future {
        let future: Future = finalize_create_agreement(
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
            nonce
        );
        return future;
    }

    async function finalize_create_agreement(
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
        nonce: u64
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
            nonce
        };

        agreements.set(worker, agreement);
    }

    async transition terminate_agreement(worker: address) -> Future {
        let future: Future = finalize_terminate_agreement(worker);
        return future;
    }

    async function finalize_terminate_agreement(worker: address) {
        let original: EmploymentAgreement = agreements.get(worker);

        let terminated: EmploymentAgreement = EmploymentAgreement {
            worker: original.worker,
            employer: original.employer,
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

        agreements.set(worker, terminated);
    }

    async transition verify_agreement(worker: address) -> Future {
        let future: Future = finalize_verify_agreement(worker);
        return future;
    }

    async function finalize_verify_agreement(worker: address) {
        assert(agreements.contains(worker));
    }
}
