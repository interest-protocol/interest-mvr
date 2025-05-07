# Interest Merkle Proof

Merkle Proof is a library for verifying Merkle proofs, commonly used in blockchain applications for efficient and secure verification of data inclusion.

## Overview

The package provides core functions for working with Merkle proofs, including:

-   Verifying Merkle proofs against a root hash
-   Verifying Merkle proofs with index tracking
-   Processing proof elements efficiently
-   Handling hash pair operations

These functions are essential for implementing secure verification of data inclusion in Merkle trees.

## Modules

-   merkle_proof: Contains the core functions for Merkle proof verification
-   merkle_proof_tests: Contains tests for `merkle_proof`

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
# testnet
mvr add @interest/merkle-proof --network testnet

# mainnet
mvr add @interest/merkle-proof --network mainnet
```

### Manual

To add this library to your project, add this to your `Move.toml`.

```toml
# goes into [dependencies] section
interest_merkle_proof = { r.mvr = "@interest/merkle-proof" }

# add this section to your Move.toml
[r.mvr]
network = "mainnet"
```

### Package Ids

The package is deployed on Sui Network mainnet at: [0x2753893a5c7cab6c6509f3cfc93fdb99fddd477d70562d3c9517bbb62cb46212](https://suiscan.xyz/mainnet/object/0x2753893a5c7cab6c6509f3cfc93fdb99fddd477d70562d3c9517bbb62cb46212/contracts)

The package is deployed on Sui Network testnet at: [0xed80808cc1ab8d45b44a1d43b2a86b5655d185f19a60e07ab2f01a24c95e6a2f](https://suiscan.xyz/testnet/object/0xed80808cc1ab8d45b44a1d43b2a86b5655d185f19a60e07ab2f01a24c95e6a2f/contracts)

## How to use

In your code, import and use the package as:

```move
module my::awesome_project;

use interest_merkle_proof::merkle_proof;

public fun verify_inclusion(
    proof: vector<vector<u8>>,
    root: vector<u8>,
    leaf: vector<u8>,
    hash: |vector<u8>| -> vector<u8>
): bool {
    merkle_proof::verify!(proof, root, leaf, hash)
}

public fun verify_with_position(
    proof: vector<vector<u8>>,
    root: vector<u8>,
    leaf: vector<u8>,
    hash: |vector<u8>| -> vector<u8>
): (bool, u256) {
    merkle_proof::verify_with_index!(proof, root, leaf, hash)
}
```

## API Reference

**verify:** Verifies a Merkle proof against a root hash.

```move
public macro fun verify(
    $proof: vector<vector<u8>>,
    $root: vector<u8>,
    $leaf: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): bool
```

**verify_with_index:** Verifies a Merkle proof and returns the position index.

```move
public macro fun verify_with_index(
    $proof: vector<vector<u8>>,
    $root: vector<u8>,
    $leaf: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): (bool, u256)
```

**process_proof:** Processes a Merkle proof to compute the root hash.

```move
public macro fun process_proof(
    $proof: vector<vector<u8>>,
    $leaf: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): vector<u8
```

**hash_pair:** Efficiently hashes a pair of values in a consistent order.

```move
public macro fun hash_pair(
    $a: vector<u8>,
    $b: vector<u8>,
    $hash: |vector<u8>| -> vector<u8>,
): vector<u8>
```

## Errors

Errors are encoded in u64.

| Error code | Reason                                                 |
| ---------- | ------------------------------------------------------ |
| 0          | Proof item has a different length to the computed hash |

## Disclaimer

This is provided on an "as is" and "as available" basis.

We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

While Interest Merkle Proof has been tested, there may be parts that may exhibit unexpected emergent behavior when used with other code, or may break in future Move versions.

Please always include your own thorough tests when using Interest Merkle Proof to make sure it works correctly with your code.

## License

This package is licensed under Apache-2.0.
