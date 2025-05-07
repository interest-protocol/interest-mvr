module interest_merkle_proof::merkle_proof;

// === Errors ===

const EVectorLengthMismatch: u64 = 0;

// === Public Functions ===

public macro fun verify(
    $proof: vector<vector<u8>>,
    $root: vector<u8>,
    $leaf: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): bool {
    process_proof!($proof, $leaf, $hash) == $root
}

public macro fun verify_with_index(
    $proof: vector<vector<u8>>,
    $root: vector<u8>,
    $leaf: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): (bool, u256) {
    let proof = $proof;
    let root = $root;
    let leaf = $leaf;

    let mut computed_hash = leaf;
    let proof_length = proof.length();
    let mut i = 0;
    let mut j = 0;

    while (i < proof_length) {
        j = j * 2;
        let proof_element = proof[i];

        computed_hash = if (computed_hash.lt(proof_element))
            efficient_hash!(computed_hash, proof_element, $hash)
        else {
            j = j + 1;
            efficient_hash!(proof_element, computed_hash, $hash)
        };

        i = i + 1;
    };

    (computed_hash == root, j)
}

// === Private Functions ===

public macro fun process_proof(
    $proof: vector<vector<u8>>,
    $leaf: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): vector<u8> {
    let proof = $proof;
    let leaf = $leaf;

    proof.fold!(leaf, |computed_hash, proof_item| {
        hash_pair!(computed_hash, proof_item, $hash)
    })
}

public macro fun hash_pair(
    $a: vector<u8>,
    $b: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): vector<u8> {
    let a = $a;
    let b = $b;
    if (a.lt(b)) efficient_hash!(a, b, $hash) else efficient_hash!(b, a, $hash)
}

public macro fun efficient_hash(
    $a: vector<u8>,
    $b: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): vector<u8> {
    let mut a = $a;
    a.append($b);
    $hash(a)
}

public fun lt(a: vector<u8>, b: vector<u8>): bool {
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
