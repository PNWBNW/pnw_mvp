/// SAMPLE HELPER LIST — replace with DAO-approved credential schema in production.
/// Used to validate credential strings in a worker profile before proof generation.

pub fn allowed_credentials() -> Vec<&'static str> {
    vec![
        // Core ZPass tiers
        "ZPassLevel1_Basic",
        "ZPassLevel2_Intermediate",
        "ZPassLevel3_Agritech",
        "ZPassLevel4_Lead",

        // Agriculture and food industry certs
        "CertifiedHarvestTech_2025",
        "CropTrace_Certified",
        "ColdStorage_Certified",
        "OrganicSoil_Certified",
        "WPS_Trainer",
        "Pesticide_Handler_Level1",
        "Pesticide_Handler_Level2",

        // Safety and compliance
        "OSHA_10",
        "OSHA_30",
        "Forklift_Operator",
        "ConfinedSpace_Cleared",

        // Logistics and traceability
        "ChainOfCustody_Expert",
        "GeoTag_Supervisor",
        "LotTracking_Lead",
        "BatchCert_Exporter",

        // Optional local skills
        "FieldSupervision_Cert",
        "Timekeeper_Certified",
        "LineWorker_Accredited",

        // Legacy or employer-issued
        "EmployerVerified_CropLead",
        "EmployerVerified_IrrigationTech",
    ]
}

/// Checks all input credentials against the sample allowlist
pub fn validate_credentials(user_credentials: &[String]) -> Result<(), String> {
    let allowed = allowed_credentials();
    for cred in user_credentials {
        if !allowed.contains(&cred.as_str()) {
            return Err(format!("Credential '{}' is not in the allowlist.", cred));
        }
    }
    Ok(())
}
