module interest_price_oracle::price_oracle;

use interest_math::fixed18::{Self, Fixed18};
use std::type_name::{Self, TypeName};
use sui::{bag::{Self, Bag}, clock::Clock, dynamic_field as df, vec_set::{Self, VecSet}};

// === Structs ===

public struct ExtensionKey<phantom Ext>() has copy, drop, store;

public struct Extension has store {
    bag: Bag,
    is_enabled: bool,
}

public struct PriceOracle has key, store {
    id: UID,
    feeds: VecSet<TypeName>,
    time_buffer_ms: u64,
    deviation: Fixed18,
    asset: TypeName,
    admin: Option<TypeName>,
}

public struct Report has copy, drop, store {
    timestamp_ms: u64,
    price: Fixed18,
    feed: TypeName,
}

public struct Request {
    reports: vector<Report>,
    oracle: address,
}

public struct Price has drop {
    asset: TypeName,
    oracle: address,
    value: u256,
    decimals: u8,
    timestamp_ms: u64,
}

// === Public Mutative Functions ===

public fun request(self: &PriceOracle): Request {
    assert!(
        self.feeds.size() != 0,
        interest_price_oracle::oracle_errors::oracle_must_have_feeds!(),
    );

    Request {
        oracle: self.id.to_address(),
        reports: vector[],
    }
}

public fun report<Feed: drop>(
    request: &mut Request,
    _: &Feed,
    price: u128,
    timestamp_ms: u64,
    decimals: u8,
) {
    assert!(price != 0, interest_price_oracle::oracle_errors::invalid_price!());
    assert!(timestamp_ms != 0, interest_price_oracle::oracle_errors::invalid_timestamp_ms!());

    let report = Report {
        timestamp_ms,
        price: price.to_fixed18(decimals),
        feed: type_name::get<Feed>(),
    };

    request.reports.push_back(report);
}

public fun destroy_request(request: Request, oracle: &PriceOracle, clock: &Clock): Price {
    let Request { oracle: oracle_address, reports } = request;

    assert!(
        oracle.id.to_address() == oracle_address,
        interest_price_oracle::oracle_errors::invalid_oracle!(),
    );

    let leader_price = reports[0].price;
    let leader_timestamp_ms = reports[0].timestamp_ms;
    let current_timestamp_ms = clock.timestamp_ms();

    reports.zip_do_ref!(oracle.feeds.keys(), |report, feed| {
        assert!(report.feed == feed, interest_price_oracle::oracle_errors::invalid_report!());
        assert!(
            report.timestamp_ms + oracle.time_buffer_ms > current_timestamp_ms,
            interest_price_oracle::oracle_errors::price_is_stale!(),
        );

        let deviation = leader_price.diff(report.price).div_up(leader_price);
        assert!(
            deviation.lte(oracle.deviation),
            interest_price_oracle::oracle_errors::price_deviation_too_high!(),
        );
    });

    Price {
        oracle: oracle_address,
        asset: oracle.asset,
        value: leader_price.to_u256(decimals!()),
        decimals: decimals!(),
        timestamp_ms: leader_timestamp_ms,
    }
}

// === Public View Functions ===

public fun price_oracle(price: &Price): address {
    price.oracle
}

public fun price_asset(price: &Price): TypeName {
    price.asset
}

public fun price_value(price: &Price): u256 {
    price.value
}

public fun price_decimals(price: &Price): u8 {
    price.decimals
}

public fun price_timestamp_ms(price: &Price): u64 {
    price.timestamp_ms
}

// === Admin Functions ===

public fun new<Asset, Admin: drop>(_: &Admin, ctx: &mut TxContext): PriceOracle {
    PriceOracle {
        id: object::new(ctx),
        feeds: vec_set::empty(),
        time_buffer_ms: 0,
        deviation: fixed18::from_raw_u128(0),
        asset: type_name::get<Asset>(),
        admin: option::some(type_name::get<Admin>()),
    }
}

public fun add_feed<Feed, Admin: drop>(self: &mut PriceOracle, _: &Admin, _: &mut TxContext) {
    self.assert_admin!<Admin>();

    self.feeds.insert(type_name::get<Feed>());
}

public fun remove_feed<Feed, Admin: drop>(self: &mut PriceOracle, _: &Admin, _: &mut TxContext) {
    self.assert_admin!<Admin>();

    self.feeds.remove(&type_name::get<Feed>());
}

public fun update_time_buffer_ms<Admin: drop>(
    self: &mut PriceOracle,
    _: &Admin,
    time_buffer_ms: u64,
    _: &mut TxContext,
) {
    self.assert_admin!<Admin>();

    assert!(time_buffer_ms != 0, interest_price_oracle::oracle_errors::invalid_time_buffer_ms!());
    self.time_buffer_ms = time_buffer_ms;
}

public fun update_deviation<Admin: drop>(
    self: &mut PriceOracle,
    _: &Admin,
    deviation: u128,
    _: &mut TxContext,
) {
    self.assert_admin!<Admin>();

    assert!(deviation != 0, interest_price_oracle::oracle_errors::invalid_deviation!());
    self.deviation = fixed18::from_raw_u128(deviation);
}

public fun add_extension<Admin: drop, Ext: drop>(
    self: &mut PriceOracle,
    _: &Admin,
    _: Ext,
    ctx: &mut TxContext,
) {
    self.assert_admin!<Admin>();

    df::add(
        &mut self.id,
        ExtensionKey<Ext>(),
        Extension {
            bag: bag::new(ctx),
            is_enabled: true,
        },
    )
}

public fun remove_extension<Ext: drop>(self: &mut PriceOracle, _: Ext) {
    let Extension { bag, .. } = df::remove(&mut self.id, ExtensionKey<Ext>());
    bag.destroy_empty();
}

public fun enable_extension<Ext: drop>(self: &mut PriceOracle, _: Ext) {
    extension_mut!<Ext>(self).is_enabled = true;
}

public fun disable_extension<Ext: drop>(self: &mut PriceOracle, _: Ext) {
    extension_mut!<Ext>(self).is_enabled = false;
}

public fun bag<Ext: drop>(self: &PriceOracle, _: Ext): &Bag {
    &self.extension!<Ext>().bag
}

public fun bag_mut<Ext: drop>(self: &mut PriceOracle, _: Ext): &mut Bag {
    self.assert_extension_is_enabled!<Ext>();

    &mut self.extension_mut!<Ext>().bag
}

// === Private Functions ===

macro fun assert_admin<$Admin>($self: &PriceOracle) {
    let self = $self;
    assert!(
        *self.admin.borrow() == type_name::get<$Admin>(),
        interest_price_oracle::oracle_errors::invalid_admin!(),
    );
}

macro fun assert_extension_is_enabled<$Ext>($self: &PriceOracle) {
    let self = $self;
    assert!(
        self.extension!<$Ext>().is_enabled,
        interest_price_oracle::oracle_errors::extension_not_enabled!(),
    );
}

macro fun extension<$Ext>($self: &PriceOracle): &Extension {
    let self = $self;
    df::borrow(&self.id, ExtensionKey<$Ext>())
}

macro fun extension_mut<$Ext>($self: &mut PriceOracle): &mut Extension {
    let self = $self;
    df::borrow_mut(&mut self.id, ExtensionKey<$Ext>())
}

// === Constants ===

macro fun decimals(): u8 {
    18
}

// === Aliases ===

use fun fixed18::u128_to_fixed18 as u128.to_fixed18;

public use fun price_asset as Price.asset;
public use fun price_value as Price.value;
public use fun price_oracle as Price.oracle;
public use fun price_decimals as Price.decimals;
public use fun price_timestamp_ms as Price.timestamp_ms;

// === Test Only Functions ===

#[test_only]
public fun price_for_testing(
    oracle: address,
    asset: TypeName,
    value: u256,
    decimals: u8,
    timestamp_ms: u64,
): Price {
    Price {
        oracle,
        asset,
        value,
        decimals,
        timestamp_ms,
    }
}
