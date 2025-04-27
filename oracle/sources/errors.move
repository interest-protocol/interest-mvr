module interest_price_oracle::oracle_errors;

#[test_only]
const EInvalidTimeLimitMs: u64 = 0;

#[test_only]
const EInvalidDeviation: u64 = 1;

#[test_only]
const EInvalidAdmin: u64 = 2;

#[test_only]
const EOracleMustHaveFeeds: u64 = 3;

#[test_only]
const EInvalidPrice: u64 = 4;

#[test_only]
const EInvalidTimestampMs: u64 = 5;

#[test_only]
const EInvalidOracle: u64 = 6;

#[test_only]
const EInvalidReport: u64 = 7;

#[test_only]
const EPriceIsStale: u64 = 8;

#[test_only]
const EPriceDeviationTooHigh: u64 = 9;

#[test_only]
const EExtensionNotFound: u64 = 10;

public(package) macro fun invalid_time_limit_ms(): u64 {
    0
}

public(package) macro fun invalid_deviation(): u64 {
    1
}

public(package) macro fun invalid_admin(): u64 {
    2
}

public(package) macro fun oracle_must_have_feeds(): u64 {
    3
}

public(package) macro fun invalid_price(): u64 {
    4
}

public(package) macro fun invalid_timestamp_ms(): u64 {
    5
}

public(package) macro fun invalid_oracle(): u64 {
    6
}

public(package) macro fun invalid_report(): u64 {
    7
}

public(package) macro fun price_is_stale(): u64 {
    8
}

public(package) macro fun price_deviation_too_high(): u64 {
    9
}

public(package) macro fun extension_not_found(): u64 {
    10
}
