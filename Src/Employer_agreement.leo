import credits.aleo;
import subDAO_reserve.aleo;
import oversightDAO_reserve.aleo;

program employer_agreement.aleo {
    // Mappings
    mapping employer_registry: [u8; 32] => bool; // Uses employer ANS instead of address
    mapping employer_tax_compliance: [u8; 32] => bool;
    mapping ans_registry: [u8; 32] => [u8; 32]; // Employer ANS mapping
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32]; // Reverse lookup for ANS
    mapping subDAO_ans_registry: [u8; 32] => [u8; 32]; // SubDAO ANS mapping
    mapping subDAO_reverse_lookup: [u8; 32] => [u8; 32]; // Reverse lookup for SubDAO ANS

    // Constants
    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";
    const OVERSIGHT_ALLOCATION: u64 = 17u64;

    // Structs
    struct Employer {
        employer_ans: [u8; 32],
        registered: bool,
        tax_compliant: bool,
        last_updated: u64
    }

    // Transition: Register employer using ANS
    transition register_employer(employer_ans: [u8; 32]) -> Employer {
        assert(!employer_registry.contains(employer_ans));
        employer_registry[employer_ans] = true;
        employer_tax_compliance[employer_ans] = false;
        
        let employer_record: Employer = Employer {
            employer_ans: employer_ans,
            registered: true,
            tax_compliant: false,
            last_updated: block.height
        };
        return employer_record;
    }

    // Transition: Verify employer tax compliance
    transition verify_employer_tax(employer_ans: [u8; 32]) -> Employer {
        assert(employer_registry.contains(employer_ans));
        employer_tax_compliance[employer_ans] = true;
        
        let employer_record: Employer = Employer {
            employer_ans: employer_ans,
            registered: true,
            tax_compliant: true,
            last_updated: block.height
        };
        return employer_record;
    }

    // Transition: Register employer ANS
    transition register_employer_ans(employer_ans: [u8; 32], ans_name: [u8; 32]) -> bool {
        assert(employer_registry.contains(employer_ans));
        assert(!ans_reverse_lookup.contains(ans_name));
        ans_registry[employer_ans] = ans_name;
        ans_reverse_lookup[ans_name] = employer_ans;
        return true;
    }

    // Transition: Register SubDAO ANS
    transition register_subDAO_ans(subdao_ans: [u8; 32], ans_name: [u8; 32]) -> bool {
        assert(!subDAO_ans_registry.contains(subdao_ans));
        assert(!subDAO_reverse_lookup.contains(ans_name));
        subDAO_ans_registry[subdao_ans] = ans_name;
        subDAO_reverse_lookup[ans_name] = subdao_ans;
        return true;
    }

    // Transition: Fund payroll pool, splitting to OversightDAO and SubDAO
    transition fund_payroll_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
        let employer_ans: [u8; 32] = ans_reverse_lookup[self.caller];
        assert(employer_registry.contains(employer_ans));
        assert(employer_tax_compliance[employer_ans]);
        assert(amount > 0u64);

        let oversight_amount: u64 = amount.checked_mul(OVERSIGHT_ALLOCATION).checked_div(100u64);
        let subDAO_amount: u64 = amount.checked_sub(oversight_amount);

        credits.aleo::transfer_public(oversightDAO_reserve.aleo::lookup_subDAO_by_ans(OVERSIGHT_DAO_ANS), oversight_amount);
        oversightDAO_reserve.aleo::deposit(OVERSIGHT_DAO_ANS, oversight_amount);

        credits.aleo::transfer_public(subDAO_reserve.aleo::lookup_subDAO_by_ans(subdao_ans), subDAO_amount);
        subDAO_reserve.aleo::deposit(subdao_ans, subDAO_amount);
        
        return true;
    }

    // Function: Lookup employer by ANS
    function lookup_employer_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }

    // Function: Lookup SubDAO by ANS
    function lookup_subDAO_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(subDAO_reverse_lookup.contains(ans_name));
        return subDAO_reverse_lookup[ans_name];
    }
}
