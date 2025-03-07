import credits.leo;
import subdao_reserve.leo;
import oversightdao_reserve.leo;

program employer_agreement.leo {
    mapping employer_registry: [u8; 32] => bool;
    mapping employer_tax_compliance: [u8; 32] => bool;
    mapping ans_registry: [u8; 32] => [u8; 32];
    mapping ans_reverse_lookup: [u8; 32] => [u8; 32];
    mapping subDAO_ans_registry: [u8; 32] => [u8; 32];
    mapping subDAO_reverse_lookup: [u8; 32] => [u8; 32];

    const OVERSIGHT_DAO_ANS: [u8; 32] = *b"oversightdao.pnw.ans";
    const OVERSIGHT_ALLOCATION: u64 = 17u64;

    struct Employer {
        employer_ans: [u8; 32],
        registered: bool,
        tax_compliant: bool,
        last_updated: u64
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

    async transition register_subDAO_ans(subdao_ans: [u8; 32], ans_name: [u8; 32]) -> (bool, async transition) {
        assert(!subDAO_ans_registry.contains(subdao_ans));
        assert(!subDAO_reverse_lookup.contains(ans_name));

        Mapping::set(subDAO_ans_registry, subdao_ans, ans_name);
        Mapping::set(subDAO_reverse_lookup, ans_name, subdao_ans);

        return (true, register_subDAO_ans);
    }

    transition fund_payroll_pool(subdao_ans: [u8; 32], amount: u64) -> bool {
        let employer_ans: [u8; 32] = ans_reverse_lookup[self.caller];
        assert(employer_registry.contains(employer_ans));
        assert(employer_tax_compliance[employer_ans]);
        assert(amount > 0u64);

        let oversight_amount: u64 = amount.checked_mul(OVERSIGHT_ALLOCATION).checked_div(100u64);
        let subdao_amount: u64 = amount.checked_sub(oversight_amount);

        credits.leo::transfer_public(oversightdao_reserve.leo::lookup_subdao_by_ans(OVERSIGHT_DAO_ANS), oversight_amount);
        oversightdao_reserve.leo::deposit(OVERSIGHT_DAO_ANS, oversight_amount);

        credits.leo::transfer_public(subdao_reserve.leo::lookup_subdao_by_ans(subdao_ans), subdao_amount);
        subdao_reserve.leo::deposit(subdao_ans, subdao_amount);

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
