/*
 * @title Fixed Point 64
 *
 * @notice A library to perform math operations over an unsigned integer with 64-bit precision.
 *
 * @dev Any operation that results in a number larger than the maximum unsigned 128 bit, will be considered an overflow and throw.
 * @dev All credits to Aptos - https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/framework/aptos-stdlib/sources/fixed_point64.move
 */
module interest_math::fixed_point64;

use interest_math::{u128, u256};

// === Constants ===

// @dev Natural log 2 in 32-bit fixed point. ln(2) in fixed 64 representation.
const LN2: u256 = 12786308645202655660;
// @dev Maximum Unsigned 128 Bit number
const MAX_U128: u256 = 340282366920938463463374607431768211455;

// === Errors ===

// @dev It is thrown if an operation results in a negative number.
const ENegativeResult: u64 = 0;
// @dev It is thrown if an operation results in a value outside of 2^-64 .. 2^64-1.
const EOutOfRange: u64 = 1;
// @dev It is thrown if a multiplication operation results in a number larger or equal to `MAX_U128`.
const EMultiplicationOverflow: u64 = 2;
// @dev It is thrown if one tries to divide by zero.
const EZeroDivision: u64 = 3;
// @dev If the result of a division operation results in a number larger or equal to `MAX_U128`.
const EDivisionOverflow: u64 = 4;
// @dev Abort code on overflow.
const EOverflowExp: u64 = 5;

// === Structs ===

public struct FixedPoint64(u128) has copy, drop, store;

// === Public-View Functions ===

public fun value(self: FixedPoint64): u128 {
    self.0
}

// === Convert Functions ===

public fun from(value: u128): FixedPoint64 {
    let scaled_value = (value as u256) << 64;
    assert!(scaled_value <= MAX_U128, EOutOfRange);
    FixedPoint64(scaled_value as u128)
}

public fun from_raw_value(value: u128): FixedPoint64 {
    FixedPoint64(value)
}

public fun from_rational(numerator: u128, denominator: u128): FixedPoint64 {
    let scaled_numerator = (numerator as u256) << 64;
    assert!(denominator != 0, EZeroDivision);
    let quotient = scaled_numerator / (denominator as u256);
    assert!(quotient != 0 || numerator == 0, EOutOfRange);
    assert!(quotient <= MAX_U128, EOutOfRange);
    FixedPoint64(quotient as u128)
}

public fun to_u128(self: FixedPoint64): u128 {
    let floored_num = to_u128_down(self) << 64;
    let boundary = floored_num + ((1 << 64) / 2);
    if (self.0 < boundary) {
        floored_num >> 64
    } else {
        to_u128_up(self)
    }
}

public fun to_u128_down(self: FixedPoint64): u128 {
    self.0 >> 64
}

public fun to_u128_up(self: FixedPoint64): u128 {
    let floored_num = to_u128_down(self) << 64;
    if (self.0 == floored_num) {
        return floored_num >> 64
    };
    let val = ((floored_num as u256) + (1 << 64));
    (val >> 64 as u128)
}

// === Comparison Functions ===

public fun is_zero(self: FixedPoint64): bool {
    self.0 == 0
}

public fun eq(x: FixedPoint64, y: FixedPoint64): bool {
    x.0 == y.0
}

public fun lt(x: FixedPoint64, y: FixedPoint64): bool {
    x.0 < y.0
}

public fun gt(x: FixedPoint64, y: FixedPoint64): bool {
    x.0 > y.0
}

public fun lte(x: FixedPoint64, y: FixedPoint64): bool {
    x.0 <= y.0
}

public fun gte(x: FixedPoint64, y: FixedPoint64): bool {
    x.0 >= y.0
}

public fun max(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
    if (x.0 > y.0) x else y
}

public fun min(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
    if (x.0 < y.0) x else y
}

// === Math Operations ===

public fun sub(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
    let x_raw = x.0;
    let y_raw = y.0;
    assert!(x_raw >= y_raw, ENegativeResult);
    FixedPoint64(x_raw - y_raw)
}

public fun add(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
    let x_raw = x.0;
    let y_raw = y.0;
    let result = (x_raw as u256) + (y_raw as u256);
    assert!(result <= MAX_U128, EOutOfRange);
    FixedPoint64(result as u128)
}

public fun mul(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
    FixedPoint64(((((x.0 as u256) * (y.0 as u256)) >> 64) as u128))
}

public fun div(x: FixedPoint64, y: FixedPoint64): FixedPoint64 {
    assert!(y.0 != 0, EZeroDivision);
    FixedPoint64(u256::div_down((x.0 as u256) << 64, (y.0 as u256)) as u128)
}

public fun mul_div(x: FixedPoint64, y: FixedPoint64, z: FixedPoint64): FixedPoint64 {
    assert!(z.0 != 0, EZeroDivision);
    FixedPoint64(u128::mul_div_down(x.0, y.0, z.0))
}

public fun mul_u128(x: u128, y: FixedPoint64): u128 {
    let unscaled_product = (x as u256) * (y.0 as u256);
    let product = unscaled_product >> 64;
    assert!(MAX_U128 >= product, EMultiplicationOverflow);
    (product as u128)
}

public fun div_down_u128(numerator: u128, denominator: FixedPoint64): u128 {
    assert!(denominator.0 != 0, EZeroDivision);
    let scaled_value = (numerator as u256) << 64;
    let quotient = u256::div_down(scaled_value, (denominator.0 as u256));
    assert!(quotient <= MAX_U128, EDivisionOverflow);
    (quotient as u128)
}

public fun div_up_u128(numerator: u128, denominator: FixedPoint64): u128 {
    assert!(denominator.0 != 0, EZeroDivision);
    let scaled_value = (numerator as u256) << 64;
    let quotient = u256::div_up(scaled_value, (denominator.0 as u256));
    assert!(quotient <= MAX_U128, EDivisionOverflow);
    (quotient as u128)
}

public fun pow(base: FixedPoint64, exponent: u64): FixedPoint64 {
    let raw_value = (base.0 as u256);
    FixedPoint64(pow_raw(raw_value, (exponent as u128)) as u128)
}

public fun sqrt(x: FixedPoint64): FixedPoint64 {
    let y = x.0;
    let mut z = (u128::sqrt_down(y) << 32 as u256);
    z = (z + ((y as u256) << 64) / z) >> 1;
    FixedPoint64(z as u128)
}

public fun exp(x: FixedPoint64): FixedPoint64 {
    let raw_value = (x.0 as u256);
    FixedPoint64(exp_raw(raw_value) as u128)
}

// === Private Functions ===

fun exp_raw(x: u256): u256 {
    // exp(x / 2^64) = 2^(x / (2^64 * ln(2))) = 2^(floor(x / (2^64 * ln(2))) + frac(x / (2^64 * ln(2))))
    let shift_long = x / LN2;
    assert!(shift_long <= 63, EOverflowExp);
    let shift = (shift_long as u8);
    let remainder = x % LN2;
    // At this point we want to calculate 2^(remainder / ln2) << shift
    // ln2 = 580 * 22045359733108027
    let bigfactor = 22045359733108027;
    let exponent = remainder / bigfactor;
    let x = remainder % bigfactor;
    // 2^(remainder / ln2) = (2^(1/580))^exponent * exp(x / 2^64)
    let roottwo = 18468802611690918839;
    // fixed point representation of 2^(1/580)
    // 2^(1/580) = roottwo(1 - eps), so the number we seek is roottwo^exponent (1 - eps * exponent)
    let mut power = pow_raw(roottwo, (exponent as u128));
    let eps_correction = 219071715585908898;
    power = power - ((power * eps_correction * exponent) >> 128);
    // x is fixed point number smaller than bigfactor/2^64 < 0.0011 so we need only 5 tayler steps
    // to get the 15 digits of precission
    let taylor1 = (power * x) >> (64 - shift);
    let taylor2 = (taylor1 * x) >> 64;
    let taylor3 = (taylor2 * x) >> 64;
    let taylor4 = (taylor3 * x) >> 64;
    let taylor5 = (taylor4 * x) >> 64;
    let taylor6 = (taylor5 * x) >> 64;
    (power << shift) + taylor1 + taylor2 / 2 + taylor3 / 6 + taylor4 / 24 + taylor5 / 120 +
        taylor6 / 720
}

fun pow_raw(mut x: u256, mut n: u128): u256 {
    let mut res: u256 = 1 << 64;
    while (n != 0) {
        if (n & 1 != 0) {
            res = (res * x) >> 64;
        };
        n = n >> 1;
        x = (x * x) >> 64;
    };
    res
}
