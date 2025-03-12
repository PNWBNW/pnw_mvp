import credits.aleo;
import subdao_reserve.aleo;
import oversightdao_reserve.aleo;

program employer_agreement.aleo {
    mapping employer_registry: [u8; 32] => bool;
    mapping employer_tax_compliance: [u8; 32] => bool;
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];
    mapping subdao_ans_registry: [u8; 32] => [u8; 32];
    mapping subdao_reverse_lookup: [u8; 32] => [u8; 32];

    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";
    const OVERSIGHT_ALLOCATION: u64 = 17u64;

    struct Employer {
        employer_ans: [u8; 32],
        registered: bool,
        tax_compliant: bool,
        last_updated: u64
    }import credits.aleo;
import subdao_reserve.aleo;
import oversightdao_reserve.aleo;

program employer_agreement.aleo {
    mapping employer_registry: [u8; 32] => bool;
    mapping employer_tax_compliance: [u8; 32] => bool;
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];

    const OVERSIGHT_DAO_ANS: [u8; 32] = encode_ans(b"oversightdao.pnw.ans");

    function encode_ans(ans_name: bytes) -> [u8; 32] {
        return hash_arc721(ans_name);
    }

    async transition register_employer(employer_ans: [u8; 32]) -> bool {
        assert(!employer_registry.contains(employer_ans));

        employer_registry.set(employer_ans, true);
        employer_tax_compliance.set(employer_ans, false);

        return true;
    }

    async transition register_employer_ans(employer_ans: [u8; 32], ans_name: bytes) -> bool {
        let encoded_ans: [u8; 32] = encode_ans(ans_name);

        assert(employer_registry.contains(employer_ans));
        assert(!ans_reverse_lookup.contains(encoded_ans));

        ans_registry.set(employer_ans, encoded_ans);
        ans_reverse_lookup.set(encoded_ans, employer_ans);

        return true;
    }

    async transition verify_employer_tax(employer_ans: [u8; 32]) -> bool {
        assert(employer_registry.contains(employer_ans));
        employer_tax_compliance.set(employer_ans, true);
        return true;
    }

    async transition finalize_employer_registration(employer_ans: [u8; 32]) -> bool {
        assert(employer_registry.contains(employer_ans));
        return true;
    }

    function lookup_employer_by_ans(ans_name: bytes) -> [u8; 32] {
        let encoded_ans: [u8; 32] = encode_ans(ans_name);
        assert(ans_reverse_lookup.contains(encoded_ans));
        return ans_reverse_lookup.get_or_use(encoded_ans, [0u8; 32]);
    }
}

    async transition register_employer(employer_ans: [u8; 32]) -> (Employer, async transition) {
        assert(!employer_registry.contains(employer_ans));

        Mapping::set(employer_registry, employer_ans, true);
        Mapping::set(employer_tax_compliance, employer_ans, false);

        let employer_record: Employer = Employer {
            employer_ans,
            registered: true,
            tax_compliant: false,
            last_updated: block.height
        };

        return (employer_record, register_employer);
    }

    async transition verify_employer_tax(employer_ans: [u8; 32]) -> (Employer, async transition) {
        assert(employer_registry.contains(employer_ans));

        Mapping::set(employer_tax_compliance, employer_ans, true);

        let employer_record: Employer = Employer {
            employer_ans,
            registered: true,
            tax_compliant: true,
            last_updated: block.height
        };

        return (employer_record, verify_employer_tax);
    }

    async transition register_employer_ans(employer_ans: [u8; 32], ans_name: [u8; 32]) -> (bool, async transition) {
        assert(employer_registry.contains(employer_ans));
        assert(!ans_reverse_lookup.contains(ans_name));

        Mapping::set(ans_registry, employer_ans, ans_name);
        Mapping::set(ans_reverse_lookup, ans_name, employer_ans);

        return (true, register_employer_ans);
    }

    async transition register_subdao_ans(subdao_ans: [u8; 32], ans_name: [u8; 32]) -> (bool, async transition) {
        assert(!subDAO_ans_registry.contains(subdao_ans));
        assert(!subDAO_reverse_lookup.contains(ans_name));

        Mapping::set(subdao_ans_registry, subdao_ans, ans_name);
        Mapping::set(subdao_reverse_lookup, ans_name, subdao_ans);

        return (true, register_subdao_ans);
    }

    transition fund_payroll_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
        let employer_ans: [u8; 32] = ans_reverse_lookup[self.caller];
        assert(employer_registry.contains(employer_ans));
        assert(employer_tax_compliance[employer_ans]);
        assert(amount > 0u64);

        let oversight_amount: u64 = amount.checked_mul(OVERSIGHT_ALLOCATION).checked_div(100u64);
        let subdao_amount: u64 = amount.checked_sub(oversight_amount);

        credits.aleo::transfer_public(oversightdao_reserve.aleo::lookup_subdao_by_ans(OVERSIGHT_DAO_ANS), oversight_amount);
        oversightdao_reserve.aleo::deposit(OVERSIGHT_DAO_ANS, oversight_amount);

        credits.aleo::transfer_public(subdao_reserve.aleo::lookup_subdao_by_ans(subdao_ans), subdao_amount);
        subdao_reserve.aleo::deposit(subdao_ans, subdao_amount);

        return true;
    }

    function lookup_employer_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(ans_reverse_lookup.contains(ans_name));
        return ans_reverse_lookup[ans_name];
    }

    function lookup_subdao_by_ans(ans_name: [u8; 32]) -> [u8; 32] {
        assert(subdao_reverse_lookup.contains(ans_name));
        return subdao_reverse_lookup[ans_name];
    }
}
