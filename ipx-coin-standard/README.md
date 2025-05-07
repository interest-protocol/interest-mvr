# IPX Coin Standard

A Move library that wraps `sui::coin::TreasuryCap` and adds capabilities to mint, burn and manage the metadata of coins.

## Overview

The package provides essential functionality for managing coins on the Sui Network, including:

-   Minting new coins with supply control
-   Burning coins with flexible permission models
-   Managing coin metadata (name, symbol, description, icon)
-   Maximum supply enforcement
-   Event emission for all operations

## Modules

-   `ipx_coin_standard`: Main module providing coin management capabilities

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
# testnet
mvr add @interest/coin-standard --network testnet

# mainnet
mvr add @interest/coin-standard --network mainnet
```

### Manual

To add this library to your project, add this to your `Move.toml`.

```toml
# goes into [dependencies] section
ipx_coin_standard = { r.mvr = "@interest/coin-standard" }

# add this section to your Move.toml
[r.mvr]
network = "mainnet"
```

### Package IDs

The package is deployed on Sui Network mainnet at: [0xa204bd0d48d49fc7b8b05c8ef3f3ae63d1b22d157526a88b91391b41e6053157](https://suiscan.xyz/mainnet/object/0xa204bd0d48d49fc7b8b05c8ef3f3ae63d1b22d157526a88b91391b41e6053157/contracts)

The package is deployed on Sui Network testnet at: [0x3d9d9cf7f37daa21d6439bb4f3e90b49312cc1471e159e0b34ef18a36332ccda](https://suiscan.xyz/testnet/object/0x3d9d9cf7f37daa21d6439bb4f3e90b49312cc1471e159e0b34ef18a36332ccda/contracts)

The mainnet package is immutable for security reasons.

## How to use

In your code, import and use the package as:

```move
module my::awesome_project;

use ipx_coin_standard::ipx_coin_standard::{Self, IPXTreasuryStandard};

// Example using coin standard
public fun create_coin<T>(
    cap: TreasuryCap<T>,
    ctx: &mut TxContext
): (IPXTreasuryStandard, Witness) {
    ipx_coin_standard::new(cap, ctx)
}
```

## API Reference

### Errors

```move
/// Error raised when a capability (MintCap, BurnCap, or MetadataCap) is invalid
/// or doesn't match the treasury it's being used with
const EInvalidCap: u64 = 0;

/// Error raised when attempting to create a capability that has already been created
/// Each capability (MintCap, BurnCap, MetadataCap) can only be created once
const ECapAlreadyCreated: u64 = 1;

/// Error raised when attempting to burn coins through the treasury
/// when public burning is not enabled
const ETreasuryCannotBurn: u64 = 2;

/// Error raised when a treasury operation is attempted with an invalid treasury
/// This usually means the treasury address doesn't match the expected one
const EInvalidTreasury: u64 = 3;

/// Error raised when attempting to mint coins that would exceed the maximum supply
/// This only applies if a maximum supply has been set
const EMaximumSupplyExceeded: u64 = 4;
```

### Structs

```move
public struct Witness {
    ipx_treasury: address,
    name: TypeName,
    mint_cap: Option<address>,
    burn_cap: Option<address>,
    metadata_cap: Option<address>,
    maximum_supply: Option<u64>,
}

public struct MintCap has key, store {
    id: UID,
    ipx_treasury: address,
    name: TypeName,
}

public struct BurnCap has key, store {
    id: UID,
    ipx_treasury: address,
    name: TypeName,
}

public struct MetadataCap has key, store {
    id: UID,
    ipx_treasury: address,
    name: TypeName,
}

public struct IPXTreasuryStandard has key, store {
    id: UID,
    name: TypeName,
    can_burn: bool,
    maximum_supply: Option<u64>,
}
```

### Events

```move
public struct New has copy, drop {
    name: TypeName,
    ipx_treasury: address,
    treasury: address,
    mint_cap: Option<address>,
    burn_cap: Option<address>,
    metadata_cap: Option<address>,
}

public struct Mint(TypeName, u64) has copy, drop;
public struct Burn(TypeName, u64) has copy, drop;

public struct DestroyMintCap has copy, drop {
    ipx_treasury: address,
    name: TypeName,
}

public struct DestroyBurnCap has copy, drop {
    ipx_treasury: address,
    name: TypeName,
}

public struct DestroyMetadataCap has copy, drop {
    ipx_treasury: address,
    name: TypeName,
}

public struct UpdateName(TypeName, string::String) has copy, drop;
public struct UpdateSymbol(TypeName, ascii::String) has copy, drop;
public struct UpdateDescription(TypeName, string::String) has copy, drop;
public struct UpdateIconUrl(TypeName, ascii::String) has copy, drop;
```

### Public Mutative Functions

```move
/// Creates a new IPXTreasuryStandard and Witness
public fun new<T>(cap: TreasuryCap<T>, ctx: &mut TxContext): (IPXTreasuryStandard, Witness)

/// Sets the maximum supply for the coin
public fun set_maximum_supply(witness: &mut Witness, maximum_supply: u64)
```

### Capabilities API

```move
/// Creates a new MintCap
public fun create_mint_cap(witness: &mut Witness, ctx: &mut TxContext): MintCap

/// Creates a new BurnCap
public fun create_burn_cap(witness: &mut Witness, ctx: &mut TxContext): BurnCap

/// Creates a new MetadataCap
public fun create_metadata_cap(witness: &mut Witness, ctx: &mut TxContext): MetadataCap

/// Allows public burning of coins
public fun allow_public_burn(witness: &mut Witness, self: &mut IPXTreasuryStandard)

/// Destroys the witness after initialization
public fun destroy_witness<T>(self: &mut IPXTreasuryStandard, witness: Witness)

/// Destroys a MintCap
public fun destroy_mint_cap(cap: MintCap)

/// Destroys a BurnCap
public fun destroy_burn_cap(cap: BurnCap)

/// Destroys a MetadataCap
public fun destroy_metadata_cap(cap: MetadataCap)
```

### Mint/Burn API

```move
/// Mints new coins
public fun mint<T>(
    cap: &MintCap,
    self: &mut IPXTreasuryStandard,
    amount: u64,
    ctx: &mut TxContext,
): Coin<T>

/// Burns coins using BurnCap
public fun cap_burn<T>(cap: &BurnCap, self: &mut IPXTreasuryStandard, coin: Coin<T>)

/// Burns coins using treasury
public fun treasury_burn<T>(self: &mut IPXTreasuryStandard, coin: Coin<T>)
```

### Metadata API

```move
/// Updates the coin name
public fun update_name<T>(
    self: &IPXTreasuryStandard,
    metadata: &mut CoinMetadata<T>,
    cap: &MetadataCap,
    name: string::String,
)

/// Updates the coin symbol
public fun update_symbol<T>(
    self: &IPXTreasuryStandard,
    metadata: &mut CoinMetadata<T>,
    cap: &MetadataCap,
    symbol: ascii::String,
)

/// Updates the coin description
public fun update_description<T>(
    self: &IPXTreasuryStandard,
    metadata: &mut CoinMetadata<T>,
    cap: &MetadataCap,
    description: string::String,
)

/// Updates the coin icon URL
public fun update_icon_url<T>(
    self: &IPXTreasuryStandard,
    metadata: &mut CoinMetadata<T>,
    cap: &MetadataCap,
    url: ascii::String,
)
```

### Public View Functions

```move
/// Returns the total supply of coins
public fun total_supply<T>(self: &IPXTreasuryStandard): u64

/// Returns the maximum supply of coins
public fun maximum_supply(self: &IPXTreasuryStandard): Option<u64>

/// Returns whether public burning is allowed
public fun can_burn(self: &IPXTreasuryStandard): bool

/// Returns the IPX treasury address from a MintCap
public fun mint_cap_ipx_treasury(cap: &MintCap): address

/// Returns the IPX treasury address from a BurnCap
public fun burn_cap_ipx_treasury(cap: &BurnCap): address

/// Returns the IPX treasury address from a MetadataCap
public fun metadata_cap_ipx_treasury(cap: &MetadataCap): address

/// Returns the name from an IPXTreasuryStandard
public fun ipx_treasury_cap_name(cap: &IPXTreasuryStandard): TypeName

/// Returns the name from a MintCap
public fun mint_cap_name(cap: &MintCap): TypeName

/// Returns the name from a BurnCap
public fun burn_cap_name(cap: &BurnCap): TypeName

/// Returns the name from a MetadataCap
public fun metadata_cap_name(cap: &MetadataCap): TypeName
```

### Method Aliases

```move
public use fun cap_burn as BurnCap.burn;
public use fun treasury_burn as IPXTreasuryStandard.burn;

public use fun mint_cap_ipx_treasury as MintCap.ipx_treasury;
public use fun burn_cap_ipx_treasury as BurnCap.ipx_treasury;
public use fun metadata_cap_ipx_treasury as MetadataCap.ipx_treasury;

public use fun ipx_treasury_cap_name as IPXTreasuryStandard.name;
public use fun mint_cap_name as MintCap.name;
public use fun burn_cap_name as BurnCap.name;
public use fun metadata_cap_name as MetadataCap.name;

public use fun destroy_mint_cap as MintCap.destroy;
public use fun destroy_burn_cap as BurnCap.destroy;
public use fun destroy_metadata_cap as MetadataCap.destroy;
```

## Disclaimer

This is provided on an "as is" and "as available" basis.

We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

While IPX Coin Standard has been tested, there may be parts that may exhibit unexpected emergent behavior when used with other code, or may break in future Move versions.

Please always include your own thorough tests when using IPX Coin Standard to make sure it works correctly with your code.

## License

This package is licensed under Apache-2.0.
