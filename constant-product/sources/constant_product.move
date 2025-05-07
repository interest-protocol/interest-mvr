module interest_constant_product::constant_product;

// === Public-View Functions ===

public macro fun k($x: u64, $y: u64): u128 {
    ($x as u128) * ($y as u128)
}

public macro fun get_amount_in($coin_out_amount: u64, $balance_in: u64, $balance_out: u64): u64 {
    assert!(
        $coin_out_amount != 0,
        interest_constant_product::constant_product_errors::no_zero_coin!(),
    );
    assert!(
        $balance_in != 0 && $balance_out != 0 && $balance_out > $coin_out_amount,
        interest_constant_product::constant_product_errors::insufficient_liquidity!(),
    );

    let (coin_out_amount, balance_in, balance_out) = (
        $coin_out_amount as u128,
        $balance_in as u128,
        $balance_out as u128,
    );

    let numerator = balance_in * coin_out_amount;
    let denominator = balance_out - coin_out_amount;

    ((if (numerator == 0) 0 else 1 + (numerator - 1) / denominator) as u64)
}

public macro fun get_amount_out($coin_in_amount: u64, $balance_in: u64, $balance_out: u64): u64 {
    assert!(
        $coin_in_amount != 0,
        interest_constant_product::constant_product_errors::no_zero_coin!(),
    );
    assert!(
        $balance_in != 0 && $balance_out != 0,
        interest_constant_product::constant_product_errors::insufficient_liquidity!(),
    );

    let (coin_in_amount, balance_in, balance_out) = (
        $coin_in_amount as u128,
        $balance_in as u128,
        $balance_out as u128,
    );

    let numerator = balance_out * coin_in_amount;
    let denominator = balance_in + coin_in_amount;

    ((numerator / denominator) as u64)
}
