import aleo_std::context::*;
import aleo_std::mapping::*;
import aleo_std::assert::*;
import aleo_std::crypto::*;
import aleo_std::bytes::*;
import aleo_std::field::*;
import aleo_std::math::*;
import aleo_std::option::*;
import aleo_std::result::*;
import aleo_std::env::*;
import aleo_std::record::*;
import worker_profiles::*;
import subdao_reserve::*;

// Program definition
program employer_agreement.aleo {

    // Mappings
    mapping employer_records: address => [u8; 64];
    mapping worker_profiles: address => [u8; 64];
    mapping employer_registry: [u8; 32] => bool;
    mapping employer_tax_compliance: [u8; 32] => bool;
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

    // Transition: Register a new employer with identity
    transition register_employer(employer: address, employer_data: [u8; 64]) -> bool {
        employer_records[employer] = employer_data;
        return true;
    }

    // Transition: Link worker identity to employer
    transition link_worker_to_employer(employer: address, worker: address, worker_data: [u8; 64]) -> bool {
        assert employer == caller, "Unauthorized access";
        worker_profiles[worker] = worker_data;
        return true;
    }

    // Transition: Employer retrieves their data
    transition get_employer_data(employer: address) -> [u8; 64] {
        assert employer == caller, "Unauthorized access";
        return employer_records[employer];
    }

    // Transition: Employer retrieves worker data
    transition get_worker_data(employer: address, worker: address) -> [u8; 64] {
        assert employer == caller, "Unauthorized access";
        return worker_profiles[worker];
    }

    // Transition: Register employer with ANS hash
    transition register_employer_ans(employer_ans: [u8; 32], ans_name: bytes) -> bool {
        let encoded_ans: [u8; 32] = encode_ans(ans_name);
        assert(!employer_registry.contains(employer_ans));
        assert(!ans_reverse_lookup.contains(encoded_ans));

        employer_registry.set(employer_ans, true);
        employer_tax_compliance.set(employer_ans, false);
        ans_registry.set(employer_ans, encoded_ans);
        ans_reverse_lookup.set(encoded_ans, employer_ans);

        return true;
    }

    // Transition: Verify employer's tax compliance
    transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
        assert(employer_registry.contains(employer_ans));
        employer_tax_compliance.set(employer_ans, true);
        return true;
    }

    // Transition: Final confirmation step (minimal for now)
    transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
        assert(employer_registry.contains(employer_ans));
        return true;
    }

    // Function: Reverse lookup for employer address using ANS name
    function lookup_employer_by_ans(ans_name: bytes) -> [u8; 32] {
        let encoded_ans: [u8; 32] = encode_ans(ans_name);
        assert(ans_reverse_lookup.contains(encoded_ans));
        return ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32]);
    }
}
