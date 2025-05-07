# Interest Math

A set of math libraries used by Interest Protocol for handling various numeric operations and fixed-point arithmetic.

## Overview

The package provides essential mathematical operations and utilities for working with different numeric types, including:

-   Fixed-point arithmetic with high precision
-   Utility functions for unsigned integers (u64, u128, u256)
-   Utility functions for signed integers (i32, i64, i128, i256)
-   Safe mathematical operations with overflow checks

These functions are crucial for implementing secure and precise financial calculations in the Interest Protocol.

## Modules

-   `fixed18`: Fixed point arithmetic with 1e18 precision
-   `u64`: Utility functions for u64
-   `u128`: Utility functions for u128
-   `u256`: Utility functions for u256
-   `i32`: Utility functions for i32
-   `i64`: Utility functions for i64
-   `i128`: Utility functions for i128
-   `i256`: Utility functions for i256

## Installing

### [Move Registry CLI](https://docs.suins.io/move-registry)

```bash
# testnet
mvr add @interest/math --network testnet

# mainnet
mvr add @interest/math --network mainnet
```

### Manual

To add this library to your project, add this to your `Move.toml`.

```toml
# goes into [dependencies] section
interest_math = { r.mvr = "@interest/math" }

# add this section to your Move.toml
[r.mvr]
network = "mainnet"
```

### Package IDs

The package is deployed on Sui Network mainnet at: [0xc9e327ded995f2f1d983537b21f027935479e702a6a1f64bd3aefd47c077ba8e](https://mainnet.suivision.xyz/package/0xc9e327ded995f2f1d983537b21f027935479e702a6a1f64bd3aefd47c077ba8e?tab=Code)

The package is deployed on Sui Network testnet at: [0x8891fdb1d8259c554c988ab994d2a73d10e26b217104336e0d4ac968a7bc0da5](https://testnet.suivision.xyz/package/0x8891fdb1d8259c554c988ab994d2a73d10e26b217104336e0d4ac968a7bc0da5?tab=Code)

## How to use

In your code, import and use the package as:

```move
module my::awesome_project;

use interest_math::u64;

// Example using u64 utilities
public fun safe_add(
    a: u64,
    b: u64
): u64 {
    u64::add(a, b)
}
```

## API Reference

### Fixed18 Module

The `fixed18` module provides fixed-point arithmetic with 1e18 precision. All operations maintain precision and handle overflow/underflow safely.

#### Structs

```move
public struct Fixed18 has copy, drop, store { value: u256 }
```

#### Conversion Functions

```move
/// Returns the raw u256 value of a Fixed18
public fun raw_value(self: Fixed18): u256

/// Creates a Fixed18 from a u256 value
public fun from_u256(value: u256): Fixed18

/// Creates a Fixed18 from a u128 value
public fun from_u128(value: u128): Fixed18

/// Creates a Fixed18 from a u64 value
public fun from_u64(value: u64): Fixed18

/// Creates a Fixed18 from a raw u256 value
public fun from_raw_u256(value: u256): Fixed18

/// Creates a Fixed18 from a raw u128 value
public fun from_raw_u128(value: u128): Fixed18

/// Creates a Fixed18 from a raw u64 value
public fun from_raw_u64(value: u64): Fixed18

/// Converts a Fixed18 to u256 with specified decimals
public fun to_u256(x: Fixed18, decimals: u8): u256

/// Converts a Fixed18 to u128 with specified decimals
public fun to_u128(x: Fixed18, decimals: u8): u128

/// Converts a Fixed18 to u64 with specified decimals
public fun to_u64(x: Fixed18, decimals: u8): u64

/// Converts a Fixed18 to u256 with specified decimals, rounding up
public fun to_u256_up(x: Fixed18, decimals: u8): u256

/// Converts a Fixed18 to u128 with specified decimals, rounding up
public fun to_u128_up(x: Fixed18, decimals: u8): u128

/// Converts a Fixed18 to u64 with specified decimals, rounding up
public fun to_u64_up(x: Fixed18, decimals: u8): u64

/// Converts a u64 to Fixed18 with specified decimals
public fun u64_to_fixed18(x: u64, decimals: u8): Fixed18

/// Converts a u128 to Fixed18 with specified decimals
public fun u128_to_fixed18(x: u128, decimals: u8): Fixed18

/// Converts a u256 to Fixed18 with specified decimals
public fun u256_to_fixed18(x: u256, decimals: u8): Fixed18

/// Converts a u64 to Fixed18 with specified decimals, rounding up
public fun u64_to_fixed18_up(x: u64, decimals: u8): Fixed18

/// Converts a u128 to Fixed18 with specified decimals, rounding up
public fun u128_to_fixed18_up(x: u128, decimals: u8): Fixed18

/// Converts a u256 to Fixed18 with specified decimals, rounding up
public fun u256_to_fixed18_up(x: u256, decimals: u8): Fixed18
```

#### Try Functions

```move
/// Attempts to add two Fixed18 numbers, returns (success, result)
public fun try_add(x: Fixed18, y: Fixed18): (bool, Fixed18)

/// Attempts to subtract two Fixed18 numbers, returns (success, result)
public fun try_sub(x: Fixed18, y: Fixed18): (bool, Fixed18)

/// Attempts to multiply two Fixed18 numbers with rounding down, returns (success, result)
public fun try_mul_down(x: Fixed18, y: Fixed18): (bool, Fixed18)

/// Attempts to multiply two Fixed18 numbers with rounding up, returns (success, result)
public fun try_mul_up(x: Fixed18, y: Fixed18): (bool, Fixed18)

/// Attempts to divide two Fixed18 numbers with rounding down, returns (success, result)
public fun try_div_down(x: Fixed18, y: Fixed18): (bool, Fixed18)

/// Attempts to divide two Fixed18 numbers with rounding up, returns (success, result)
public fun try_div_up(x: Fixed18, y: Fixed18): (bool, Fixed18)
```

#### Arithmetic Functions

```move
/// Adds two Fixed18 numbers
public fun add(x: Fixed18, y: Fixed18): Fixed18

/// Subtracts two Fixed18 numbers
public fun sub(x: Fixed18, y: Fixed18): Fixed18

/// Returns the absolute difference between two Fixed18 numbers
public fun diff(x: Fixed18, y: Fixed18): Fixed18

/// Returns the average of two Fixed18 numbers
public fun average(x: Fixed18, y: Fixed18): Fixed18

/// Multiplies two Fixed18 numbers with rounding down
public fun mul_down(x: Fixed18, y: Fixed18): Fixed18

/// Multiplies two Fixed18 numbers with rounding up
public fun mul_up(x: Fixed18, y: Fixed18): Fixed18

/// Divides two Fixed18 numbers with rounding down
public fun div_down(x: Fixed18, y: Fixed18): Fixed18

/// Divides two Fixed18 numbers with rounding up
public fun div_up(x: Fixed18, y: Fixed18): Fixed18
```

#### Comparison Functions

```move
/// Check if a is greater than b
public fun gt(a: Fixed18, b: Fixed18): bool

/// Check if a is less than b
public fun lt(a: Fixed18, b: Fixed18): bool

/// Check if a is greater than or equal to b
public fun gte(a: Fixed18, b: Fixed18): bool

/// Check if a is less than or equal to b
public fun lte(a: Fixed18, b: Fixed18): bool

/// Check if value is zero
public fun is_zero(value: Fixed18): bool
```

#### Utility Functions

```move
/// Returns the base value (1e18) used for fixed point arithmetic
public macro fun base(): u256

/// Returns zero in Fixed18 format
public fun zero(): Fixed18

/// Returns one in Fixed18 format
public fun one(): Fixed18
```

### U64 Module

The `u64` module provides safe arithmetic operations for u64 integers with overflow checks.

#### Constants

```move
const MAX_U64: u256 = 0xFFFFFFFFFFFFFFFF;
const WRAPPING_MAX: u256 = MAX_U64 + 1;
```

#### Wrapping Functions

```move
/// Adds two u64 numbers with wrapping arithmetic
public fun wrapping_add(x: u64, y: u64): u64

/// Subtracts two u64 numbers with wrapping arithmetic
public fun wrapping_sub(x: u64, y: u64): u64

/// Multiplies two u64 numbers with wrapping arithmetic
public fun wrapping_mul(x: u64, y: u64): u64
```

#### Try Functions

```move
/// Attempts to add two u64 numbers, returns (success, result)
public fun try_add(x: u64, y: u64): (bool, u64)

/// Attempts to subtract two u64 numbers, returns (success, result)
public fun try_sub(x: u64, y: u64): (bool, u64)

/// Attempts to multiply two u64 numbers, returns (success, result)
public fun try_mul(x: u64, y: u64): (bool, u64)

/// Attempts to divide two u64 numbers with rounding down, returns (success, result)
public fun try_div_down(x: u64, y: u64): (bool, u64)

/// Attempts to divide two u64 numbers with rounding up, returns (success, result)
public fun try_div_up(x: u64, y: u64): (bool, u64)

/// Attempts to multiply and divide three u64 numbers with rounding down, returns (success, result)
public fun try_mul_div_down(x: u64, y: u64, z: u64): (bool, u64)

/// Attempts to multiply and divide three u64 numbers with rounding up, returns (success, result)
public fun try_mul_div_up(x: u64, y: u64, z: u64): (bool, u64)

/// Attempts to calculate modulo of two u64 numbers, returns (success, result)
public fun try_mod(x: u64, y: u64): (bool, u64)
```

#### Arithmetic Functions

```move
/// Adds two u64 numbers, aborts on overflow
public fun add(x: u64, y: u64): u64

/// Subtracts two u64 numbers, aborts on underflow
public fun sub(x: u64, y: u64): u64

/// Multiplies two u64 numbers, aborts on overflow
public fun mul(x: u64, y: u64): u64

/// Divides two u64 numbers with rounding down, aborts on division by zero
public fun div_down(x: u64, y: u64): u64

/// Divides two u64 numbers with rounding up, aborts on division by zero
public fun div_up(a: u64, b: u64): u64

/// Multiplies and divides three u64 numbers with rounding down
public fun mul_div_down(x: u64, y: u64, z: u64): u64

/// Multiplies and divides three u64 numbers with rounding up
public fun mul_div_up(x: u64, y: u64, z: u64): u64
```

#### Comparison Functions

```move
/// Returns the minimum of two u64 numbers
public fun min(x: u64, y: u64): u64

/// Returns the maximum of two u64 numbers
public fun max(x: u64, y: u64): u64

/// Clamps a u64 number between lower and upper bounds
public fun clamp(x: u64, lower: u64, upper: u64): u64

/// Returns the absolute difference between two u64 numbers
public fun diff(x: u64, y: u64): u64

/// Raises a u64 number to the power of another u64 number
public fun pow(x: u64, n: u64): u64
```

#### Vector Functions

```move
/// Calculates the sum of a vector of u64 numbers
public fun sum(nums: vector<u64>): u64

/// Calculates the average of two u64 numbers
public fun average(x: u64, y: u64): u64

/// Calculates the average of a vector of u64 numbers
public fun average_vector(nums: vector<u64>): u64
```

#### Square Root Functions

```move
/// Calculates the square root of a u64 number with rounding down
public fun sqrt_down(x: u64): u64

/// Calculates the square root of a u64 number with rounding up
public fun sqrt_up(a: u64): u64
```

#### Logarithmic Functions

```move
/// Calculates the base-2 logarithm of a u64 number with rounding down
public fun log2_down(value: u64): u8

/// Calculates the base-2 logarithm of a u64 number with rounding up
public fun log2_up(value: u64): u16

/// Calculates the base-10 logarithm of a u64 number with rounding down
public fun log10_down(value: u64): u8

/// Calculates the base-10 logarithm of a u64 number with rounding up
public fun log10_up(value: u64): u8

/// Calculates the base-256 logarithm of a u64 number with rounding down
public fun log256_down(x: u64): u8

/// Calculates the base-256 logarithm of a u64 number with rounding up
public fun log256_up(x: u64): u8
```

#### Utility Functions

```move
/// Returns the maximum value for u64
public macro fun max_value(): u64
```

### U128 Module

The `u128` module provides safe arithmetic operations for u128 integers with overflow checks.

#### Constants

```move
const MAX_U128: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
```

#### Try Functions

```move
/// Attempts to add two u128 numbers, returns (success, result)
public fun try_add(x: u128, y: u128): (bool, u128)

/// Attempts to subtract two u128 numbers, returns (success, result)
public fun try_sub(x: u128, y: u128): (bool, u128)

/// Attempts to multiply two u128 numbers, returns (success, result)
public fun try_mul(x: u128, y: u128): (bool, u128)

/// Attempts to divide two u128 numbers with rounding down, returns (success, result)
public fun try_div_down(x: u128, y: u128): (bool, u128)

/// Attempts to divide two u128 numbers with rounding up, returns (success, result)
public fun try_div_up(x: u128, y: u128): (bool, u128)

/// Attempts to multiply and divide three u128 numbers with rounding down, returns (success, result)
public fun try_mul_div_down(x: u128, y: u128, z: u128): (bool, u128)

/// Attempts to multiply and divide three u128 numbers with rounding up, returns (success, result)
public fun try_mul_div_up(x: u128, y: u128, z: u128): (bool, u128)

/// Attempts to calculate modulo of two u128 numbers, returns (success, result)
public fun try_mod(x: u128, y: u128): (bool, u128)
```

#### Arithmetic Functions

```move
/// Adds two u128 numbers, aborts on overflow
public fun add(x: u128, y: u128): u128

/// Subtracts two u128 numbers, aborts on underflow
public fun sub(x: u128, y: u128): u128

/// Multiplies two u128 numbers, aborts on overflow
public fun mul(x: u128, y: u128): u128

/// Divides two u128 numbers with rounding down, aborts on division by zero
public fun div_down(x: u128, y: u128): u128

/// Divides two u128 numbers with rounding up, aborts on division by zero
public fun div_up(a: u128, b: u128): u128

/// Multiplies and divides three u128 numbers with rounding down
public fun mul_div_down(x: u128, y: u128, z: u128): u128

/// Multiplies and divides three u128 numbers with rounding up
public fun mul_div_up(x: u128, y: u128, z: u128): u128
```

#### Comparison Functions

```move
/// Returns the minimum of two u128 numbers
public fun min(a: u128, b: u128): u128

/// Returns the maximum of two u128 numbers
public fun max(x: u128, y: u128): u128

/// Clamps a u128 number between lower and upper bounds
public fun clamp(x: u128, lower: u128, upper: u128): u128

/// Returns the absolute difference between two u128 numbers
public fun diff(x: u128, y: u128): u128

/// Raises a u128 number to the power of another u128 number
public fun pow(n: u128, e: u128): u128
```

#### Vector Functions

```move
/// Calculates the sum of a vector of u128 numbers
public fun sum(nums: vector<u128>): u128

/// Calculates the average of two u128 numbers
public fun average(a: u128, b: u128): u128

/// Calculates the average of a vector of u128 numbers
public fun average_vector(nums: vector<u128>): u128
```

#### Square Root Functions

```move
/// Calculates the square root of a u128 number with rounding down
public fun sqrt_down(x: u128): u128

/// Calculates the square root of a u128 number with rounding up
public fun sqrt_up(x: u128): u128
```

#### Logarithmic Functions

```move
/// Calculates the base-2 logarithm of a u128 number with rounding down
public fun log2_down(x: u128): u8

/// Calculates the base-2 logarithm of a u128 number with rounding up
public fun log2_up(x: u128): u16

/// Calculates the base-10 logarithm of a u128 number with rounding down
public fun log10_down(x: u128): u8

/// Calculates the base-10 logarithm of a u128 number with rounding up
public fun log10_up(x: u128): u8

/// Calculates the base-256 logarithm of a u128 number with rounding down
public fun log256_down(x: u128): u8

/// Calculates the base-256 logarithm of a u128 number with rounding up
public fun log256_up(x: u128): u8
```

#### Utility Functions

```move
/// Returns the maximum value for u128
public macro fun max_value(): u128
```

### U256 Module

The `u256` module provides safe arithmetic operations for u256 integers with overflow checks.

#### Constants

```move
const MAX_U256: u256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
```

#### Try Functions

```move
/// Attempts to add two u256 numbers, returns (success, result)
public fun try_add(x: u256, y: u256): (bool, u256)

/// Attempts to subtract two u256 numbers, returns (success, result)
public fun try_sub(x: u256, y: u256): (bool, u256)

/// Attempts to multiply two u256 numbers, returns (success, result)
public fun try_mul(x: u256, y: u256): (bool, u256)

/// Attempts to divide two u256 numbers with rounding down, returns (success, result)
public fun try_div_down(x: u256, y: u256): (bool, u256)

/// Attempts to divide two u256 numbers with rounding up, returns (success, result)
public fun try_div_up(x: u256, y: u256): (bool, u256)

/// Attempts to multiply and divide three u256 numbers with rounding down, returns (success, result)
public fun try_mul_div_down(x: u256, y: u256, z: u256): (bool, u256)

/// Attempts to multiply and divide three u256 numbers with rounding up, returns (success, result)
public fun try_mul_div_up(x: u256, y: u256, z: u256): (bool, u256)

/// Attempts to calculate modulo of two u256 numbers, returns (success, result)
public fun try_mod(x: u256, y: u256): (bool, u256)
```

#### Arithmetic Functions

```move
/// Adds two u256 numbers, aborts on overflow
public fun add(x: u256, y: u256): u256

/// Subtracts two u256 numbers, aborts on underflow
public fun sub(x: u256, y: u256): u256

/// Multiplies two u256 numbers, aborts on overflow
public fun mul(x: u256, y: u256): u256

/// Divides two u256 numbers with rounding down, aborts on division by zero
public fun div_down(x: u256, y: u256): u256

/// Divides two u256 numbers with rounding up, aborts on division by zero
public fun div_up(x: u256, y: u256): u256

/// Multiplies and divides three u256 numbers with rounding down
public fun mul_div_down(x: u256, y: u256, z: u256): u256

/// Multiplies and divides three u256 numbers with rounding up
public fun mul_div_up(x: u256, y: u256, z: u256): u256
```

#### Comparison Functions

```move
/// Returns the minimum of two u256 numbers
public fun min(x: u256, y: u256): u256

/// Returns the maximum of two u256 numbers
public fun max(x: u256, y: u256): u256

/// Clamps a u256 number between lower and upper bounds
public fun clamp(x: u256, lower: u256, upper: u256): u256

/// Returns the absolute difference between two u256 numbers
public fun diff(x: u256, y: u256): u256
```

#### Exponential Functions

```move
/// Raises a u256 number to the power of another u256 number
public fun pow(n: u256, e: u256): u256
```

#### Vector Functions

```move
/// Calculates the sum of a vector of u256 numbers
public fun sum(nums: vector<u256>): u256

/// Calculates the average of two u256 numbers
public fun average(x: u256, y: u256): u256

/// Calculates the average of a vector of u256 numbers
public fun average_vector(nums: vector<u256>): u256
```

#### Square Root Functions

```move
/// Calculates the square root of a u256 number with rounding down
public fun sqrt_down(x: u256): u256

/// Calculates the square root of a u256 number with rounding up
public fun sqrt_up(a: u256): u256
```

#### Logarithmic Functions

```move
/// Calculates the base-2 logarithm of a u256 number with rounding down
public fun log2_down(value: u256): u8

/// Calculates the base-2 logarithm of a u256 number with rounding up
public fun log2_up(value: u256): u16

/// Calculates the base-10 logarithm of a u256 number with rounding down
public fun log10_down(value: u256): u8

/// Calculates the base-10 logarithm of a u256 number with rounding up
public fun log10_up(value: u256): u8

/// Calculates the base-256 logarithm of a u256 number with rounding down
public fun log256_down(x: u256): u8

/// Calculates the base-256 logarithm of a u256 number with rounding up
public fun log256_up(x: u256): u8
```

#### Utility Functions

```move
/// Returns the maximum value for u256
public macro fun max_value(): u256
```

### I32 Module

The `i32` module provides safe arithmetic operations for i32 integers with overflow checks.

#### Constants

```move
const MAX_U32: u32 = 0xFFFFFFFF;
const MAX_POSITIVE: u32 = 0x7FFFFFFF;
const MIN_NEGATIVE: u32 = 0x80000000;
```

#### Errors

```move
const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivByZero: u64 = 2;
const EInvalidBitShift: u64 = 3;
```

#### Structs

```move
public enum Compare has copy, drop, store {
    Less,
    Equal,
    Greater,
}

public struct I32 has copy, drop, store {
    value: u32,
}
```

#### Basic Functions

```move
/// Returns the raw u32 value of an I32
public fun value(self: I32): u32

/// Returns zero in I32 format
public fun zero(): I32

/// Returns the maximum value for I32
public fun max(): I32

/// Returns the minimum value for I32
public fun min(): I32
```

#### Conversion Functions

```move
/// Creates an I32 from a u32 value
public fun from_u32(value: u32): I32

/// Creates an I32 from a u64 value
public fun from_u64(value: u64): I32

/// Creates an I32 from a u128 value
public fun from_u128(value: u128): I32

/// Creates a negative I32 from a u32 value
public fun negative_from_u32(value: u32): I32

/// Creates a negative I32 from a u64 value
public fun negative_from_u64(value: u64): I32

/// Creates a negative I32 from a u128 value
public fun negative_from_u128(value: u128): I32

/// Converts an I32 to u32, aborts if negative
public fun to_u32(self: I32): u32

/// Converts an I32 to u64, aborts if negative
public fun to_u64(self: I32): u64

/// Converts an I32 to u128, aborts if negative
public fun to_u128(self: I32): u128

/// Truncates an I32 to u8
public fun truncate_to_u8(self: I32): u8

/// Truncates an I32 to u16
public fun truncate_to_u16(self: I32): u16
```

#### Comparison Functions

```move
/// Checks if an I32 is negative
public fun is_negative(self: I32): bool

/// Checks if an I32 is positive
public fun is_positive(self: I32): bool

/// Checks if an I32 is zero
public fun is_zero(self: I32): bool

/// Returns the absolute value of an I32
public fun abs(self: I32): I32

/// Checks if two I32s are equal
public fun eq(self: I32, other: I32): bool

/// Checks if an I32 is less than another
public fun lt(self: I32, other: I32): bool

/// Checks if an I32 is greater than another
public fun gt(self: I32, other: I32): bool

/// Checks if an I32 is less than or equal to another
public fun lte(self: I32, other: I32): bool

/// Checks if an I32 is greater than or equal to another
public fun gte(self: I32, other: I32): bool
```

#### Arithmetic Functions

```move
/// Adds two I32 numbers, aborts on overflow
public fun add(self: I32, other: I32): I32

/// Subtracts two I32 numbers, aborts on underflow
public fun sub(self: I32, other: I32): I32

/// Multiplies two I32 numbers, aborts on overflow
public fun mul(self: I32, other: I32): I32

/// Divides two I32 numbers with rounding down, aborts on division by zero
public fun div(self: I32, other: I32): I32

/// Divides two I32 numbers with rounding up, aborts on division by zero
public fun div_up(self: I32, other: I32): I32

/// Calculates modulo of two I32 numbers, aborts on division by zero
public fun mod(self: I32, other: I32): I32

/// Raises an I32 number to the power of a u32 exponent
public fun pow(self: I32, exponent: u32): I32
```

#### Wrapping Functions

```move
/// Adds two I32 numbers with wrapping arithmetic
public fun wrapping_add(self: I32, other: I32): I32

/// Subtracts two I32 numbers with wrapping arithmetic
public fun wrapping_sub(self: I32, other: I32): I32
```

#### Bitwise Functions

```move
/// Performs bitwise AND between two I32 numbers
public fun and(self: I32, other: I32): I32

/// Performs bitwise OR between two I32 numbers
public fun or(self: I32, other: I32): I32

/// Performs bitwise XOR between two I32 numbers
public fun xor(self: I32, other: I32): I32

/// Performs bitwise NOT on an I32 number
public fun not(self: I32): I32

/// Performs right shift on an I32 number
public fun shr(self: I32, rhs: u8): I32

/// Performs left shift on an I32 number
public fun shl(self: I32, lhs: u8): I32
```

### I64 Module

The `i64` module provides safe arithmetic operations for i64 integers with overflow checks.

#### Constants

```move
const MAX_U64: u64 = 0xFFFFFFFFFFFFFFFF;
const MAX_POSITIVE: u64 = 0x7FFFFFFFFFFFFFFF;
const MIN_NEGATIVE: u64 = 0x8000000000000000;
```

#### Errors

```move
const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivByZero: u64 = 2;
const EInvalidBitShift: u64 = 3;
```

#### Structs

```move
public enum Compare has copy, drop, store {
    Less,
    Equal,
    Greater,
}

public struct I64 has copy, drop, store {
    value: u64,
}
```

#### Basic Functions

```move
/// Returns the raw u64 value of an I64
public fun value(self: I64): u64

/// Returns zero in I64 format
public fun zero(): I64

/// Returns the maximum value for I64
public fun max(): I64

/// Returns the minimum value for I64
public fun min(): I64
```

#### Conversion Functions

```move
/// Creates an I64 from a u32 value
public fun from_u32(value: u32): I64

/// Creates an I64 from a u64 value
public fun from_u64(value: u64): I64

/// Creates an I64 from a u128 value
public fun from_u128(value: u128): I64

/// Creates a negative I64 from a u64 value
public fun negative_from_u64(value: u64): I64

/// Creates a negative I64 from a u128 value
public fun negative_from_u128(value: u128): I64

/// Converts an I64 to u64, aborts if negative
public fun to_u64(self: I64): u64

/// Converts an I64 to u128, aborts if negative
public fun to_u128(self: I64): u128

/// Truncates an I64 to u8
public fun truncate_to_u8(self: I64): u8

/// Truncates an I64 to u16
public fun truncate_to_u16(self: I64): u16

/// Truncates an I64 to u32
public fun truncate_to_u32(self: I64): u32
```

#### Comparison Functions

```move
/// Checks if an I64 is negative
public fun is_negative(self: I64): bool

/// Checks if an I64 is positive
public fun is_positive(self: I64): bool

/// Checks if an I64 is zero
public fun is_zero(self: I64): bool

/// Returns the absolute value of an I64
public fun abs(self: I64): I64

/// Checks if two I64s are equal
public fun eq(self: I64, other: I64): bool

/// Checks if an I64 is less than another
public fun lt(self: I64, other: I64): bool

/// Checks if an I64 is greater than another
public fun gt(self: I64, other: I64): bool

/// Checks if an I64 is less than or equal to another
public fun lte(self: I64, other: I64): bool

/// Checks if an I64 is greater than or equal to another
public fun gte(self: I64, other: I64): bool
```

#### Arithmetic Functions

```move
/// Adds two I64 numbers, aborts on overflow
public fun add(self: I64, other: I64): I64

/// Subtracts two I64 numbers, aborts on underflow
public fun sub(self: I64, other: I64): I64

/// Multiplies two I64 numbers, aborts on overflow
public fun mul(self: I64, other: I64): I64

/// Divides two I64 numbers with rounding down, aborts on division by zero
public fun div(self: I64, other: I64): I64

/// Divides two I64 numbers with rounding up, aborts on division by zero
public fun div_up(self: I64, other: I64): I64

/// Calculates modulo of two I64 numbers, aborts on division by zero
public fun mod(self: I64, other: I64): I64

/// Raises an I64 number to the power of a u64 exponent
public fun pow(self: I64, exponent: u64): I64
```

#### Wrapping Functions

```move
/// Adds two I64 numbers with wrapping arithmetic
public fun wrapping_add(self: I64, other: I64): I64

/// Subtracts two I64 numbers with wrapping arithmetic
public fun wrapping_sub(self: I64, other: I64): I64
```

#### Bitwise Functions

```move
/// Performs bitwise AND between two I64 numbers
public fun and(self: I64, other: I64): I64

/// Performs bitwise OR between two I64 numbers
public fun or(self: I64, other: I64): I64

/// Performs bitwise XOR between two I64 numbers
public fun xor(self: I64, other: I64): I64

/// Performs bitwise NOT on an I64 number
public fun not(self: I64): I64

/// Performs right shift on an I64 number
public fun shr(self: I64, rhs: u8): I64

/// Performs left shift on an I64 number
public fun shl(self: I64, lhs: u8): I64
```

### I128 Module

The `i128` module provides safe arithmetic operations for i128 integers with overflow checks.

#### Constants

```move
const MAX_U128: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
const MAX_POSITIVE: u128 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
const MIN_NEGATIVE: u128 = 0x80000000000000000000000000000000;
```

#### Errors

```move
const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivByZero: u64 = 2;
const EInvalidBitShift: u64 = 3;
```

#### Structs

```move
public enum Compare has copy, drop, store {
    Less,
    Equal,
    Greater,
}

public struct I128 has copy, drop, store {
    value: u128,
}
```

#### Basic Functions

```move
/// Returns the raw u128 value of an I128
public fun value(self: I128): u128

/// Returns zero in I128 format
public fun zero(): I128

/// Returns the maximum value for I128
public fun max(): I128

/// Returns the minimum value for I128
public fun min(): I128
```

#### Conversion Functions

```move
/// Creates an I128 from a u32 value
public fun from_u32(value: u32): I128

/// Creates an I128 from a u64 value
public fun from_u64(value: u64): I128

/// Creates an I128 from a u128 value
public fun from_u128(value: u128): I128

/// Creates a negative I128 from a u128 value
public fun negative_from_u128(value: u128): I128

/// Creates a negative I128 from a u64 value
public fun negative_from(value: u64): I128

/// Converts an I128 to u128, aborts if negative
public fun to_u128(self: I128): u128

/// Truncates an I128 to u8
public fun truncate_to_u8(self: I128): u8

/// Truncates an I128 to u16
public fun truncate_to_u16(self: I128): u16

/// Truncates an I128 to u32
public fun truncate_to_u32(self: I128): u32

/// Truncates an I128 to u64
public fun truncate_to_u64(self: I128): u64
```

#### Comparison Functions

```move
/// Checks if an I128 is negative
public fun is_negative(self: I128): bool

/// Checks if an I128 is positive
public fun is_positive(self: I128): bool

/// Checks if an I128 is zero
public fun is_zero(self: I128): bool

/// Returns the absolute value of an I128
public fun abs(self: I128): I128

/// Checks if two I128s are equal
public fun eq(self: I128, other: I128): bool

/// Checks if an I128 is less than another
public fun lt(self: I128, other: I128): bool

/// Checks if an I128 is greater than another
public fun gt(self: I128, other: I128): bool

/// Checks if an I128 is less than or equal to another
public fun lte(self: I128, other: I128): bool

/// Checks if an I128 is greater than or equal to another
public fun gte(self: I128, other: I128): bool
```

#### Arithmetic Functions

```move
/// Adds two I128 numbers, aborts on overflow
public fun add(self: I128, other: I128): I128

/// Subtracts two I128 numbers, aborts on underflow
public fun sub(self: I128, other: I128): I128

/// Multiplies two I128 numbers, aborts on overflow
public fun mul(self: I128, other: I128): I128

/// Divides two I128 numbers with rounding down, aborts on division by zero
public fun div(self: I128, other: I128): I128

/// Divides two I128 numbers with rounding up, aborts on division by zero
public fun div_up(self: I128, other: I128): I128

/// Calculates modulo of two I128 numbers, aborts on division by zero
public fun mod(self: I128, other: I128): I128

/// Raises an I128 number to the power of a u128 exponent
public fun pow(self: I128, exponent: u128): I128
```

#### Wrapping Functions

```move
/// Adds two I128 numbers with wrapping arithmetic
public fun wrapping_add(self: I128, other: I128): I128

/// Subtracts two I128 numbers with wrapping arithmetic
public fun wrapping_sub(self: I128, other: I128): I128
```

#### Bitwise Functions

```move
/// Performs bitwise AND between two I128 numbers
public fun and(self: I128, other: I128): I128

/// Performs bitwise OR between two I128 numbers
public fun or(self: I128, other: I128): I128

/// Performs bitwise XOR between two I128 numbers
public fun xor(self: I128, other: I128): I128

/// Performs bitwise NOT on an I128 number
public fun not(self: I128): I128

/// Performs right shift on an I128 number
public fun shr(self: I128, rhs: u8): I128

/// Performs left shift on an I128 number
public fun shl(self: I128, lhs: u8): I128
```

### I256 Module

The `i256` module provides safe arithmetic operations for i256 integers with overflow checks.

#### Constants

```move
const MAX_U256: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
const MAX_POSITIVE: u256 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
const MIN_NEGATIVE: u256 = 0x8000000000000000000000000000000000000000000000000000000000000000;
```

#### Errors

```move
const EOverflow: u64 = 0;
const EUnderflow: u64 = 1;
const EDivByZero: u64 = 2;
const EUndefined: u64 = 3;
```

#### Structs

```move
public enum Compare has copy, drop, store {
    Less,
    Equal,
    Greater,
}

public struct I256 has copy, drop, store {
    value: u256,
}
```

#### Basic Functions

```move
/// Returns the raw u256 value of an I256
public fun value(self: I256): u256

/// Returns zero in I256 format
public fun zero(): I256

/// Returns the maximum value for I256
public fun max(): I256

/// Returns the minimum value for I256
public fun min(): I256
```

#### Conversion Functions

```move
/// Creates an I256 from a u8 value
public fun from_u8(value: u8): I256

/// Creates an I256 from a u32 value
public fun from_u32(value: u32): I256

/// Creates an I256 from a u64 value
public fun from_u64(value: u64): I256

/// Creates an I256 from a u128 value
public fun from_u128(value: u128): I256

/// Creates an I256 from a u256 value
public fun from_u256(value: u256): I256

/// Creates a negative I256 from a u256 value
public fun negative_from_u256(value: u256): I256

/// Creates a negative I256 from a u64 value
public fun negative_from(value: u64): I256

/// Creates a negative I256 from a u128 value
public fun negative_from_u128(value: u128): I256

/// Converts an I256 to u8
public fun to_u8(self: I256): u8

/// Converts an I256 to u256, aborts if negative
public fun to_u256(self: I256): u256

/// Truncates an I256 to u8
public fun truncate_to_u8(self: I256): u8

/// Truncates an I256 to u16
public fun truncate_to_u16(self: I256): u16

/// Truncates an I256 to u32
public fun truncate_to_u32(self: I256): u32

/// Truncates an I256 to u64
public fun truncate_to_u64(self: I256): u64

/// Truncates an I256 to u128
public fun truncate_to_u128(self: I256): u128
```

#### Comparison Functions

```move
/// Checks if an I256 is negative
public fun is_negative(self: I256): bool

/// Checks if an I256 is positive
public fun is_positive(self: I256): bool

/// Checks if an I256 is zero
public fun is_zero(self: I256): bool

/// Returns the absolute value of an I256
public fun abs(self: I256): I256

/// Checks if two I256s are equal
public fun eq(self: I256, other: I256): bool

/// Checks if an I256 is less than another
public fun lt(self: I256, other: I256): bool

/// Checks if an I256 is greater than another
public fun gt(self: I256, other: I256): bool

/// Checks if an I256 is less than or equal to another
public fun lte(self: I256, other: I256): bool

/// Checks if an I256 is greater than or equal to another
public fun gte(self: I256, other: I256): bool
```

#### Arithmetic Functions

```move
/// Adds two I256 numbers, aborts on overflow
public fun add(self: I256, other: I256): I256

/// Subtracts two I256 numbers, aborts on underflow
public fun sub(self: I256, other: I256): I256

/// Multiplies two I256 numbers, aborts on overflow
public fun mul(self: I256, other: I256): I256

/// Divides two I256 numbers with rounding down, aborts on division by zero
public fun div(self: I256, other: I256): I256

/// Divides two I256 numbers with rounding up, aborts on division by zero
public fun div_up(self: I256, other: I256): I256

/// Calculates modulo of two I256 numbers, aborts on division by zero
public fun mod(self: I256, other: I256): I256

/// Raises an I256 number to the power of a u256 exponent
public fun pow(self: I256, exponent: u256): I256
```

#### Wrapping Functions

```move
/// Adds two I256 numbers with wrapping arithmetic
public fun wrapping_add(self: I256, other: I256): I256

/// Subtracts two I256 numbers with wrapping arithmetic
public fun wrapping_sub(self: I256, other: I256): I256
```

#### Bitwise Functions

```move
/// Performs bitwise AND between two I256 numbers
public fun and(self: I256, other: I256): I256

/// Performs bitwise OR between two I256 numbers
public fun or(self: I256, other: I256): I256

/// Performs bitwise XOR between two I256 numbers
public fun xor(self: I256, other: I256): I256

/// Performs bitwise NOT on an I256 number
public fun not(self: I256): I256

/// Performs right shift on an I256 number
public fun shr(self: I256, rhs: u8): I256

/// Performs left shift on an I256 number
public fun shl(self: I256, lhs: u8): I256
```

## Disclaimer

This is provided on an "as is" and "as available" basis.

We do not give any warranties and will not be liable for any loss incurred through any use of this codebase.

While Interest Math has been tested, there may be parts that may exhibit unexpected emergent behavior when used with other code, or may break in future Move versions.

Please always include your own thorough tests when using Interest Math to make sure it works correctly with your code.

## License

This package is licensed under Apache-2.0.
