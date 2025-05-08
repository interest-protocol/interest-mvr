module interest_exchange_rate::exchange_rate;

use interest_math::u256;

// === Structs ===

public struct ExchangeRate has copy, drop, store {
    assets: u256,
    shares: u256,
    virtual_shares: u256,
}

// === Public Mutation Functions ===

public fun new(virtual_shares: u256): ExchangeRate {
    ExchangeRate {
        assets: 0,
        shares: 0,
        virtual_shares,
    }
}

public fun new_with_values(assets: u256, shares: u256, virtual_shares: u256): ExchangeRate {
    ExchangeRate {
        assets,
        shares,
        virtual_shares,
    }
}

public fun default(): ExchangeRate {
    new(default_virtual_shares!())
}

public fun add_assets(self: &mut ExchangeRate, assets: u256) {
    self.assets = self.assets + assets;
}

public fun add_shares(self: &mut ExchangeRate, shares: u256) {
    self.shares = self.shares + shares;
}

public fun sub_assets(self: &mut ExchangeRate, assets: u256) {
    self.assets = self.assets - assets;
}

public fun sub_shares(self: &mut ExchangeRate, shares: u256) {
    self.shares = self.shares - shares;
}

// === Public View Functions ===

public fun shares(exchange_rate: ExchangeRate): u256 {
    exchange_rate.shares
}

public fun assets(exchange_rate: ExchangeRate): u256 {
    exchange_rate.assets
}

public fun virtual_shares(exchange_rate: ExchangeRate): u256 {
    exchange_rate.virtual_shares
}

public fun to_shares_down(self: ExchangeRate, assets: u256): u256 {
    u256::mul_div_down(assets, self.shares + self.virtual_shares, self.assets + virtual_assets!())
}

public fun to_shares_up(self: ExchangeRate, assets: u256): u256 {
    u256::mul_div_up(assets, self.shares + self.virtual_shares, self.assets + virtual_assets!())
}

public fun to_assets_down(self: ExchangeRate, shares: u256): u256 {
    u256::mul_div_down(shares, self.assets + virtual_assets!(), self.shares + self.virtual_shares)
}

public fun to_assets_up(self: ExchangeRate, shares: u256): u256 {
    u256::mul_div_up(shares, self.assets + virtual_assets!(), self.shares + self.virtual_shares)
}

// === Constants ===

public macro fun virtual_assets(): u256 {
    1
}

public macro fun default_virtual_shares(): u256 {
    1_000_000
}
