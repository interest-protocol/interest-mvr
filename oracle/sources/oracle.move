module interest_price_oracle::price_oracle;

use interest_access_control::access_control::AdminWitness;
use interest_math::fixed18::{Self, Fixed18};
use std::type_name::{Self, TypeName};
use sui::{clock::Clock, vec_set::{Self, VecSet}};
use sui::dynamic_field as df;
use sui::bag::{Self, Bag};

// === Structs ===

public struct ExtensionKey<phantom T>() has copy, drop, store;

public struct Extension has  store {
    bag: Bag, 
    is_enabled: bool,
    permissions: u8
}

public struct PriceOracle has key, store {
    id: UID,
    feeds: VecSet<TypeName>,
    time_limit_ms: u64,
    deviation: Fixed18,
    coin: TypeName,
    admin: TypeName,
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

public struct Price {
    coin: TypeName,
    oracle: address,
    value: u256,
    decimals: u8,
    timestamp_ms: u64,
}

// === Public Mutative Functions ===

public fun request(self: &PriceOracle): Request {
    assert!(self.feeds.size() != 0, interest_price_oracle::oracle_errors::oracle_must_have_feeds!());

    Request {
        oracle: self.id.to_address(),
        reports: vector[],
    }
}

public fun report<Witness: drop>(
    request: &mut Request,
    _: &Witness,
    price: u128,
    timestamp_ms: u64,
    decimals: u8,
) {
    assert!(price != 0, interest_price_oracle::oracle_errors::invalid_price!());
    assert!(timestamp_ms != 0, interest_price_oracle::oracle_errors::invalid_timestamp_ms!());

    let report = Report {
        timestamp_ms,
        price: price.to_fixed18(decimals),
        feed: type_name::get<Witness>(),
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
            report.timestamp_ms + oracle.time_limit_ms > current_timestamp_ms,
            interest_price_oracle::oracle_errors::price_is_stale!(),
        );

        let deviation = leader_price.diff!(report.price).mul_up(leader_price);
        assert!(
            deviation.lte(oracle.deviation),
            interest_price_oracle::oracle_errors::price_deviation_too_high!(),
        );
    });

    Price {
        oracle: oracle_address,
        coin: oracle.coin,
        value: leader_price.to_u256(decimals!()),
        decimals: decimals!(),
        timestamp_ms: leader_timestamp_ms,
    }
}

public fun destroy_price(price: Price) {
    let Price { .. } = price;
}

// === Public View Functions ===

public fun price_oracle(price: &Price): address {
    price.oracle
}

public fun price_coin(price: &Price): TypeName {
    price.coin
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

// === Package Only Functions ===

public(package) macro fun add_feed_internal<$Feed>($self: &mut PriceOracle) {
    let self = $self;
    self.feeds.insert(type_name::get<$Feed>());
}

public(package) macro fun remove_feed_internal<$Feed>($self: &mut PriceOracle) {
    let self = $self;
    self.feeds.remove(&type_name::get<$Feed>());
}

public(package) macro fun update_time_limit_ms_internal($self: &mut PriceOracle, $time_limit_ms: u64) {
    let self = $self;
    let time_limit_ms = $time_limit_ms;

    assert!(time_limit_ms != 0, interest_price_oracle::oracle_errors::invalid_time_limit_ms!());
    self.time_limit_ms = time_limit_ms;
}

public(package) macro fun update_deviation_internal($self: &mut PriceOracle, $deviation: u128) {
    let self = $self;
    let deviation = $deviation;

    assert!(deviation != 0, interest_price_oracle::oracle_errors::invalid_deviation!());
    self.deviation = fixed18::from_raw_u128(deviation);
}

// === Extension Functions === 

public fun add_extension<T, Admin>(self: &mut PriceOracle, _: &AdminWitness<Admin>, permissions: u8, ctx: &mut TxContext) { 
    self.assert_is_admin!<Admin>(); 

    df::add(&mut self.id, ExtensionKey<T>(), Extension {
        bag: bag::new(ctx),
        is_enabled: true,
        permissions,
    });
}

public fun disable_extension<T, Admin>(self: &mut PriceOracle, _: &AdminWitness<Admin>) { 
    self.assert_is_admin!<Admin>(); 
    self.assert_has_extension!<T>();

    extension_mut!<T>(self).is_enabled = false;
}

// === Admin Functions ===

public fun new<Coin, Admin>(
    _: &AdminWitness<Admin>,
    feeds: vector<TypeName>,
    time_limit_ms: u64,
    deviation: u128,
    ctx: &mut TxContext,
): PriceOracle {
    assert!(time_limit_ms != 0, interest_price_oracle::oracle_errors::invalid_time_limit_ms!());
    assert!(deviation != 0, interest_price_oracle::oracle_errors::invalid_deviation!());

    PriceOracle {
        id: object::new(ctx),
        feeds: vec_set::from_keys(feeds),
        time_limit_ms,
        deviation: fixed18::from_raw_u128(deviation),
        coin: type_name::get<Coin>(),
        admin: type_name::get<Admin>(),
    }
}

public fun admin_add_feed<Feed, Admin>(
    self: &mut PriceOracle,
    _: &AdminWitness<Admin>,
    _: &mut TxContext,
) {
    self.assert_is_admin!<Admin>();
    self.add_feed_internal!<Feed>();
}

public fun admin_remove_feed<Feed, Admin>(
    self: &mut PriceOracle,
    _: &AdminWitness<Admin>,
    _: &mut TxContext,
) {
    self.assert_is_admin!<Admin>();
    self.remove_feed_internal!<Feed>();
}

public fun admin_update_time_limit_ms<Admin>(
    self: &mut PriceOracle,
    _: &AdminWitness<Admin>,
    time_limit_ms: u64,
    _: &mut TxContext,
) {
    self.assert_is_admin!<Admin>();
    self.update_time_limit_ms_internal!(time_limit_ms);
}

public fun admin_update_deviation<Admin>(
    self: &mut PriceOracle,
    _: &AdminWitness<Admin>,
    deviation: u128,
    _: &mut TxContext,
) {
    self.assert_is_admin!<Admin>();
    self.update_deviation_internal!(deviation);
}

// === Private Functions ===

macro fun assert_is_admin<$Admin>($self: &PriceOracle) {
    let self = $self;
    assert!(self.is_admin!<$Admin>(), interest_price_oracle::oracle_errors::invalid_admin!());
}

macro fun is_admin<$Admin>($self: &PriceOracle): bool {
    let self = $self;
    self.admin == type_name::get<$Admin>()
}

macro fun fixed18_diff($a: Fixed18, $b: Fixed18): Fixed18 {
    let a = $a; 
    let b = $b;
    if (a.gte(b)) {
        a.sub(b)
    } else {
        b.sub(a)
    }
}

macro fun assert_has_extension<$T>($self: &PriceOracle) {
    let self = $self;
    assert!(self.has_extension!<$T>(), interest_price_oracle::oracle_errors::extension_not_found!());
}

macro fun has_extension<$T>($self: &PriceOracle): bool {
    let self = $self;
    df::exists_(&self.id, ExtensionKey<$T>())
}

macro fun extension<$T>($self: &PriceOracle): &Extension {
    let self = $self;
    df::borrow(&self.id, ExtensionKey<$T>())
}

macro fun extension_mut<$T>($self: &mut PriceOracle): &mut Extension {
    let self = $self;
    df::borrow_mut(&mut self.id, ExtensionKey<$T>())
}

macro fun decimals(): u8 {
    18
}

macro fun feed_permissions(): u8 {
    0
}

macro fun price_permissions(): u8 {
    1
}

// === Aliases ===

use fun fixed18_diff as Fixed18.diff;
use fun fixed18::u128_to_fixed18 as u128.to_fixed18;

public use fun price_coin as Price.coin;
public use fun price_value as Price.value;
public use fun price_oracle as Price.oracle;
public use fun destroy_price as Price.destroy;
public use fun price_decimals as Price.decimals;
public use fun price_timestamp_ms as Price.timestamp_ms;
