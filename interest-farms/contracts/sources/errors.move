module interest_farms::interest_farm_errors;

#[test_only]
const EInvalidTimestamp: u64 = 0;

public(package) macro fun invalid_timestamp(): u64 {
    0
}

#[test_only]
const EMissingRewards: u64 = 1;

public(package) macro fun missing_rewards(): u64 {
    1
}

#[test_only]
const EAccountAndFarmMismatch: u64 = 2;

public(package) macro fun account_and_farm_mismatch(): u64 {
    2
}

#[test_only]
const EZeroRewards: u64 = 3;

public(package) macro fun zero_rewards(): u64 {
    3
}

#[test_only]
const EFarmIsPaused: u64 = 4;

public(package) macro fun farm_is_paused(): u64 {
    4
}

#[test_only]
const ENonZeroRewards: u64 = 5;

public(package) macro fun non_zero_rewards(): u64 {
    5
}

#[test_only]
const EInvalidAdmin: u64 = 6;

public(package) macro fun invalid_admin(): u64 {
    6
}
