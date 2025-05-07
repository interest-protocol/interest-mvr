# Interest Constant Product

Constant Product is a library to calculate the constant product invariant for automated market makers (AMMs).

## Overview

The package provides core mathematical functions for implementing constant product AMMs, following the x \* y = k formula. It includes functions for:

-   Calculating the constant product (k)
-   Computing input amounts based on desired output
-   Computing output amounts based on input

These functions are essential for implementing decentralized exchanges and liquidity pools that use the constant product formula.

## Modules

-   constant_product: Contains the core mathematical functions for constant product calculations
-   errors: Contains all error codes thrown by the package

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
# testnet
mvr add @interest/constant-product --network testnet

# mainnet
mvr add @interest/constant-product --network mainnet
```

### Manual

To add this library to your project, add this to your `Move.toml`.

```toml
# goes into [dependencies] section
interest_constant_product = { r.mvr = "@interest/constant-product" }

# add this section to your Move.toml
[r.mvr]
network = "mainnet"
```

### Package Ids

The package is deployed on Sui Network mainnet at: [TBD]
The package is deployed on Sui Network testnet at: [TBD]

### How to use

In your code, import and use the package as:

```move
module my::awesome_project;

use interest_constant_product::constant_product;

public fun calculate_k(x: u64, y: u64): u128 {
    constant_product::k!(x, y)
}

public fun get_input_amount(amount_out: u64, reserve_in: u64, reserve_out: u64): u64 {
    constant_product::get_amount_in!(amount_out, reserve_in, reserve_out)
}

public fun get_output_amount(amount_in: u64, reserve_in: u64, reserve_out: u64): u64 {
    constant_product::get_amount_out!(amount_in, reserve_in, reserve_out)
}
```

## API Reference

**k:** Calculates the constant product (k) for two reserves.

```move
public macro fun k(x: u64, y: u64): u128
```

**get_amount_in:** Calculates the required input amount for a desired output amount, given the current reserves.

```move
public macro fun get_amount_in(coin_out_amount: u64, balance_in: u64, balance_out: u64): u64
```

**get_amount_out:** Calculates the output amount for a given input amount, given the current reserves.

```move
public macro fun get_amount_out(coin_in_amount: u64, balance_in: u64, balance_out: u64): u64
```

## Errors

Errors are encoded in u64.

| Error code | Reason                                                                      |
| ---------- | --------------------------------------------------------------------------- |
| 0          | Insufficient liquidity in the pool or one of the reserves is equal to zero. |
| 1          | Attempted to calculate an output from a zero value input                    |

## Disclaimer

This is provided on an "as is" and "as available" basis.

We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

While Interest Constant Product has been tested, there may be parts that may exhibit unexpected emergent behavior when used with other code, or may break in future Move versions.

Please always include your own thorough tests when using Interest Constant Product to make sure it works correctly with your code.

## License

This package is licensed under Apache-2.0.
