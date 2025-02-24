program certification_verifier.leo;

// Mappings
mapping approved_certifications: map[string, bool] = {};
mapping certifying_agencies: map[address, bool] = {};
mapping certification_requests: map[string, address] = {};

// Function: Register certifying agency
function register_certifying_agency(agency: address) -> bool {
    let admin: address = caller();
    assert(is_system_admin(admin), "Unauthorized access.");
    certifying_agencies[agency] = true;
    return true;
}

// Function: Request certification
function request_certification(certification: string) -> bool {
    let employer: address = caller();
    assert(is_valid_certification(certification), "Invalid certification request.");
    certification_requests[certification] = employer;
    return true;
}

// Function: Approve certification
function approve_certification(certification: string) -> bool {
    let agency: address = caller();
    assert(certifying_agencies.get_or_use(agency, false), "Unauthorized entity.");
    
    let employer = certification_requests.get_or_use(certification, 0x0);
    assert(employer != 0x0, "No pending certification request found.");
    
    approved_certifications[certification] = true;
    delete certification_requests[certification];
    return true;
}

// Function: Revoke certification
function revoke_certification(certification: string) -> bool {
    let agency: address = caller();
    assert(certifying_agencies.get_or_use(agency, false), "Unauthorized entity.");
    
    approved_certifications[certification] = false;
    return true;
}

// Function: Check if certification is approved
function is_certification_approved(certification: string) -> bool {
    return approved_certifications.get_or_use(certification, false);
}

// Helper Function: Validate certification name
function is_valid_certification(cert: string) -> bool {
    let valid_certs = ["USDA Organic", "Certified Humane", "Non-GMO", "Wild-Caught", 
                       "Farm-Raised", "Gluten-Free", "Sustainable"];
    return contains(valid_certs, cert);
}

// Helper Function: Check system admin status
function is_system_admin(entity: address) -> bool {
    let admin_list = [/* List of system admin addresses */];
    return contains(admin_list, entity);
}
