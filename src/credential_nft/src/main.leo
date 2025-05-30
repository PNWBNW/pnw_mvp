program credential_nft.aleo;

const VERIFIER_DAO: address = aleo1oversightdao000000000000000000000000000000000000000000000000000;

struct CredentialNFT {
    credential_type: u128,
    badge_level: u8,
    issued_on: u32,
    owner: address,
    is_active: bool,
    _nonce: group
}

mapping badge_registry: address => CredentialNFT;

async transition mint_badge(
    recipient: address,
    credential_type: u128,
    badge_level: u8,
    issued_on: u32,
    _nonce: group
) -> CredentialNFT {
    let sender = caller();
    assert(sender == VERIFIER_DAO);

    let existing = badge_registry.get(recipient);
    match existing {
        Some(_) => {
            panic("Badge already exists for this address");
        },
        None => {
            let badge = CredentialNFT {
                credential_type,
                badge_level,
                issued_on,
                owner: recipient,
                is_active: true,
                _nonce
            };

            badge_registry.set(recipient, badge);
            badge
        }
    }
}

async transition revoke_badge(recipient: address) -> CredentialNFT {
    let sender = caller();
    assert(sender == VERIFIER_DAO);

    let badge = badge_registry.get_or_use(recipient, CredentialNFT {
        credential_type: 0u128,
        badge_level: 0u8,
        issued_on: 0u32,
        owner: recipient,
        is_active: false,
        _nonce: 0group
    });

    let updated = CredentialNFT {
        credential_type: badge.credential_type,
        badge_level: badge.badge_level,
        issued_on: badge.issued_on,
        owner: badge.owner,
        is_active: false,
        _nonce: badge._nonce
    };

    badge_registry.set(recipient, updated);
    updated
}

async function verify_badge(address: address, credential_type: u128) -> bool {
    let badge = badge_registry.get_or_use(address, CredentialNFT {
        credential_type: 0u128,
        badge_level: 0u8,
        issued_on: 0u32,
        owner: address,
        is_active: false,
        _nonce: 0group
    });

    badge.credential_type == credential_type && badge.is_active == true
}
