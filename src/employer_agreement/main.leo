program employer_agreement.aleo {
    
    mapping employer_records: address => [u8; 64];
    mapping worker_profiles: address => [u8; 64];

    import credits.aleo;
    import worker_profiles::*;
    import subdao_reserve::*;

    // Registers employer identity data
    transition register_employer(employer: address, employer_data: [u8; 64]) -> bool {
        employer_records[employer] = employer_data;
        return true;
    }

    // Links worker data to employer identity
    transition link_worker_to_employer(employer: address, worker: address, worker_data: [u8; 64]) -> bool {
        assert employer == caller, "Unauthorized access";
        worker_profiles[worker] = worker_data;
        return true;
    }

    // Employer retrieves their own data
    transition get_employer_data(employer: address) -> [u8; 64] {
        assert employer == caller, "Unauthorized access";
        return employer_records[employer];
    }

    // Employer retrieves worker data
    transition get_worker_data(employer: address, worker: address) -> [u8; 64] {
        assert employer == caller, "Unauthorized access";
        return worker_profiles[worker];
    }
}
