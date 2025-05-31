program oversightdao_nft.aleo;

mapping nft_commits: field => bool;

const oversight_dao_address: address = aleo1...REPLACE_ME...;

/**
 * Commits NFT data and edition into a unique field.
 */
inline function commit_nft(nft_data: field, nft_edition: scalar) -> field {
    let nft_commit: field = BHP256::commit_to_field(nft_data, nft_edition);
    nft_commit
}

/**
 * Mint an NFT by committing its data and edition.
 * Only the OversightDAO can mint.
 */
async transition mint_nft(nft_data: field, nft_edition: scalar) {
    assert(caller == oversight_dao_address);

    let nft_commit: field = commit_nft(nft_data, nft_edition);
    let exists: bool = nft_commits.get(nft_commit).unwrap_or(false);
    assert(exists == false);

    nft_commits.set(nft_commit, true);
}

/**
 * Verify if an NFT commit is valid.
 */
function verify_nft_commit(nft_commit: field) -> bool {
    nft_commits.get(nft_commit).unwrap_or(false)
}

/**
 * Revoke a valid NFT.
 * DAO can either remove or mark it as false (for audit traceability).
 */
async transition revoke_nft(nft_commit: field) {
    assert(caller == oversight_dao_address);

    let exists: bool = nft_commits.get(nft_commit).unwrap_or(false);
    assert(exists == true);

    // Option 1: full removal (invisible to future queries)
    // nft_commits.remove(nft_commit);

    // Option 2: audit-preserving revocation
    nft_commits.set(nft_commit, false);
}
