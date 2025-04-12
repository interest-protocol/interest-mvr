module interest_merkle_proof::merkle_proof;

// === Errors ===

const EVectorLengthMismatch: u64 = 0;

// === Public Functions ===

public fun verify(proof: vector<vector<u8>>, root: vector<u8>, leaf: vector<u8>): bool {
    process_proof(proof, leaf) == root
}

public fun verify_with_index(
    proof: &vector<vector<u8>>,
    root: vector<u8>,
    leaf: vector<u8>,
): (bool, u256) {
    let mut computed_hash = leaf;
    let proof_length = proof.length();
    let mut i = 0;
    let mut j = 0;

    while (i < proof_length) {
        j = j * 2;
        let proof_element = proof[i];

        computed_hash = if (computed_hash.lt(proof_element))
            efficient_hash(computed_hash, proof_element)
        else {
            j = j + 1;
            efficient_hash(proof_element, computed_hash)
        };

        i = i + 1;
    };

    (computed_hash == root, j)
}

// === Private Functions ===

fun process_proof(proof: vector<vector<u8>>, leaf: vector<u8>): vector<u8> {
    proof.fold!(leaf, |computed_hash, proof_item| {
        hash_pair(computed_hash, proof_item)
    })
}

fun hash_pair(a: vector<u8>, b: vector<u8>): vector<u8> {
    if (a.lt(b)) efficient_hash(a, b) else efficient_hash(b, a)
}

fun efficient_hash(mut a: vector<u8>, b: vector<u8>): vector<u8> {
    a.append(b);
    a.sha3_256()
}

fun lt(a: vector<u8>, b: vector<u8>): bool {
    let mut i = 0;
    let len = a.length();
    assert!(len == b.length(), EVectorLengthMismatch);

    while (i < len) {
        if (a[i] < b[i]) return true;
        if (a[i] > b[i]) return false;
        i = i + 1;
    };

    false
}

// === Aliases ===

use fun lt as vector.lt;
use fun std::hash::sha3_256 as vector.sha3_256;
