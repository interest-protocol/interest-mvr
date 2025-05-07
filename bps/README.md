# Interest BPS

BPS (Basis Points) is a library for performing arithmetic operations with basis points, commonly used in financial calculations.

## Overview

The package provides core mathematical functions for working with basis points (BPS), where 1 BPS equals 0.01% and 10,000 BPS equals 100%. It includes functions for:

- Creating and managing BPS values
- Performing arithmetic operations (addition, subtraction, multiplication, division)
- Calculating percentage values from totals
- Handling rounding (up/down) in calculations

These functions are essential for implementing financial calculations that require precise percentage-based operations.

## Modules

- bps: Contains the core mathematical functions for BPS calculations
- errors: Contains all error codes thrown by the package
- bps_tests: Contains tests for `bps`

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
# testnet
mvr add @interest/bps --network testnet

# mainnet
mvr add @interest/bps --network mainnet
```

### Manual

To add this library to your project, add this to your `Move.toml`.

```toml
# goes into [dependencies] section
interest_bps = { r.mvr = "@interest/bps" }

# add this section to your Move.toml
[r.mvr]
network = "mainnet"
```

### Package Ids

The package is deployed on Sui Network mainnet at: [0xec50242b14f7ffdc37fb91ade8490cdce2f876e7e9c3c3d7d7d98e944397d8f2](https://suiscan.xyz/mainnet/object/0xec50242b14f7ffdc37fb91ade8490cdce2f876e7e9c3c3d7d7d98e944397d8f2/contracts)

The package is deployed on Sui Network testnet at: [0xea5b7f0c5ccb9fe5d7ed835b3dd1560515c016c175b3b48b12b9ad8774c2b0f1](https://suiscan.xyz/testnet/object/0xea5b7f0c5ccb9fe5d7ed835b3dd1560515c016c175b3b48b12b9ad8774c2b0f1/contracts)

## How to use

In your code, import and use the package as:

```move
module my::awesome_project;

use interest_bps::bps;

public fun calculate_percentage(bps_value: u64, total: u64): u64 {
    let bps = bps::new(bps_value);
    bps.calc(total)
}

public fun add_percentages(bps_x: u64, bps_y: u64): u64 {
    let bps1 = bps::new(bps_x);
    let bps2 = bps::new(bps_y);
    bps1.add(bps2).value()
}
```

## API Reference

**new:** Creates a new BPS struct from a raw value.

```move
public fun new(bps: u64): BPS
```

**add:** Adds two BPS values together.

```move
public fun add(bps_x: BPS, bps_y: BPS): BPS
```

**sub:** Subtracts one BPS value from another.

```move
public fun sub(bps_x: BPS, bps_y: BPS): BPS
```

**mul:** Multiplies a BPS value by a scalar.

```move
public fun mul(bps_x: BPS, scalar: u64): BPS
```

**div:** Divides a BPS value by a scalar.

```move
public fun div(bps_x: BPS, scalar: u64): BPS
```

**div_up:** Divides a BPS value by a scalar, rounding up.

```move
public fun div_up(bps_x: BPS, scalar: u64): BPS
```

**calc:** Calculates the percentage value from a total, rounding down.

```move
public fun calc(bps: BPS, total: u64): u64
```

**calc_up:** Calculates the percentage value from a total, rounding up.

```move
public fun calc_up(bps: BPS, total: u64): u64
```

**value:** Returns the raw value of a BPS struct.

```move
public fun value(bps: BPS): u64
```

**max_value:** Returns the maximum BPS value 10_000.

```move
public macro fun max_value(): u64
```

## Errors

Errors are encoded in u64.

| Error code | Reason                                                      |
| ---------- | ----------------------------------------------------------- |
| 0          | BPS value exceeds maximum allowed value (10,000)            |
| 1          | Attempted to subtract a larger BPS value from a smaller one |
| 2          | Attempted to divide by zero                                 |

## Disclaimer

This is provided on an "as is" and "as available" basis.

We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

While Interest BPS has been tested, there may be parts that may exhibit unexpected emergent behavior when used with other code, or may break in future Move versions.

Please always include your own thorough tests when using Interest BPS to make sure it works correctly with your code.

## License

This package is licensed under Apache-2.0.
