module interest_constant_product::constant_product_errors;

#[test_only]
const EInsufficientLiquidity: u64 = 0;

#[test_only]
const ENoZeroCoin: u64 = 1;

public(package) macro fun insufficient_liquidity(): u64 {
    0
}

public(package) macro fun no_zero_coin(): u64 {
    1
}
