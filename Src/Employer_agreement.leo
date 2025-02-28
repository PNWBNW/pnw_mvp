import credits.aleo;
import subDAO_reserve.aleo;
import oversightDAO_reserve.aleo;

program employer_agreement.aleo {
    // Mappings
    mapping employer_registry: address => bool;
    mapping employer_tax_compliance: address => bool;
    mapping ans_registry: address => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => address;
    mapping subDAO_ans_registry: address => [u8; 32];
    mapping subDAO_reverse_lookup: [u8; 32] => address;

    // Constants
    const SUBDAO_ANS_NAME: [u8; 32] = *b"wa001_subdao.pnw.ans            ";
    const SUBDAO_RESERVE: address = aleo1zay2jaxzyrsued32g3hmkfxr9apsaj8cjmwa9j68vrtlem5e5yys4yruyk;
    const OVERSIGHT_DAO: address = aleo1s8t86aza932zah3mv5knclvnn5zy4gedpl5a4wn5h2yrt08mxqzsw5amdd;
    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans            ";
    const OVERSIGHT_ALLOCATION: u64 = 17u64;

    // Structs
    struct Employer {
        employer_address: address,
        registered: bool,
        tax_compliant: bool,
        last_updated: u64
    }

    // Transition: Register employer
    transition register_employer(employer: address) -> Employer {
        assert(!employer_registry.contains(employer));
        employer_registry[employer] = true;
        employer_tax_compliance[employer] = false;
        
        let employer_record: Employer = Employer {
            employer_address: employer,
            registered: true,
            tax_compliant: false,
            last_updated: block.height
        };
        return employer_record;
    }

    // Transition: Verify employer tax compliance
    transition verify_employer_tax(employer: address) -> Employer {
        assert(employer_registry.contains(employer));
        employer_tax_compliance[employer] = true;
        
        let employer_record: Employer = Employer {
            employer_address: employer,
            registered: true,
            tax_compliant: true,
            last_updated: block.height
        };
        return employer_record;
    }

    // Transition: Register employer ANS
    transition register_employer_ans(employer: address, ans_name: [u8; 32]) -> bool {
        assert(employer_registry.contains(employer));
        assert(!ans_reverse_lookup.contains(ans_name));
        ans_registry[employer] = ans_name;
        ans_reverse_lookup[ans_name] = employer;
        return true;
    }

    // Transition: Register SubDAO ANS
    transition register_subDAO_ans(subDAO: address, ans_name: [u8; 32]) -> bool {
        assert(!subDAO_ans_registry.contains(subDAO));
        assert(!subDAO_reverse_lookup.contains(ans_name));
        subDAO_ans_registry[subDAO] = ans_name;
        subDAO_reverse_lookup[ans_name] = subDAO;
        return true;
    }

    // Transition: Fund payroll pool, splitting to OversightDAO and SubDAO
    transition fund_payroll_pool(subDAO: address, amount: u64) -> bool {
        let employer: address = self.caller;
        assert(employer_registry.contains(employer));
        assert(employer_tax_compliance[employer]);
        assert(amount > 0u64);

        let oversight_amount: u64 = amount * OVERSIGHT_ALLOCATION / 100u64;
        let subDAO_amount: u64 = amount - oversight_amount;

        credits.aleo::transfer_public(OVERSIGHT_DAO, oversight_amount);
        oversightDAO_reserve.aleo::deposit(OVERSIGHT_DAO, oversight_amount);

        credits.aleo::transfer_public(subDAO, subDAO_amount);
        subDAO_reserve.aleo::deposit(subDAO, subDAO_amount);
        
        return true;
    }

    // Function: Lookup employer address by ANS
    function lookup_employer_by_ans(ans_name: [u8; 32]) -> address {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }

    // Function: Lookup SubDAO address by ANS
    function lookup_subDAO_by_ans(ans_name: [u8; 32]) -> address {
        assert(subDAO_reverse_lookup.contains(ans_name));
        return subDAO_reverse_lookup[ans_name];
    }
}
