#[test_only]
module interest_farms::interest_farm_tests;

use interest_access_control::access_control;
use interest_farms::{interest_farm::{Self, InterestFarm}, ipx::{Self, IPX}};
use std::type_name;
use sui::{
    clock::{Self, Clock},
    coin::{mint_for_testing, CoinMetadata},
    sui::SUI,
    test_scenario as ts,
    test_utils::{destroy, assert_eq}
};

const ADMIN: address = @0x1;

public struct Test() has drop;

public struct USDC() has drop;

const POW_10_9: u64 = 1_000_000_000;

#[test]
fun test_new_farm() {
    let mut scenario = ts::begin(ADMIN);

    ipx::init_for_testing(scenario.ctx());

    scenario.next_tx(ADMIN);

    let start_time = 100;

    let ipx_metadata = scenario.take_shared<CoinMetadata<IPX>>();

    let admin_witness = access_control::sign_in_for_testing<Test>(0);

    let mut clock = clock::create_for_testing(scenario.ctx());

    let mut new_request_farm = interest_farm::request_new_farm<IPX, Test>(
        &clock,
        &ipx_metadata,
        &admin_witness,
        start_time,
        scenario.ctx(),
    );

    new_request_farm.register_reward<IPX, SUI>(scenario.ctx());
    new_request_farm.register_reward<IPX, USDC>(scenario.ctx());

    let mut farm = new_request_farm.new_farm<IPX>(scenario.ctx());

    assert_eq(
        interest_farm::rewards<IPX>(&farm),
        vector[type_name::get<SUI>(), type_name::get<USDC>()],
    );

    farm.assert_reward_data<IPX, SUI>(0, 0, 0, 0);
    farm.assert_reward_data<IPX, USDC>(0, 0, 0, 0);

    assert_eq(interest_farm::total_stake_amount<IPX>(&farm), 0);
    assert_eq(
        interest_farm::precision<IPX>(&farm),
        (
            10u64.pow(ipx_metadata.get_decimals()) * interest_farms::interest_farm_constants::pow_10_9!(),
        ) as u256,
    );
    assert_eq(interest_farm::start_timestamp<IPX>(&farm), start_time);
    assert_eq(interest_farm::paused<IPX>(&farm), false);

    clock.increase_seconds(1_000);

    farm.set_rewards_per_second<IPX, SUI, Test>(&clock, &admin_witness, 1_000);
    farm.add_reward<IPX, SUI>(&clock, mint_for_testing(1_000 * POW_10_9, scenario.ctx()));

    farm.assert_reward_data<IPX, SUI>(1_000 * POW_10_9, 1_000, 1_000, 0);

    clock.increase_seconds(500);

    farm.set_rewards_per_second<IPX, USDC, Test>(&clock, &admin_witness, 2_000);
    farm.add_reward<IPX, USDC>(&clock, mint_for_testing(3_500 * POW_10_9, scenario.ctx()));

    farm.assert_reward_data<IPX, USDC>(3_500 * POW_10_9, 2_000, 1_500, 0);

    scenario.end();
    destroy(ipx_metadata);
    destroy(clock);
    destroy(farm);
}

fun assert_reward_data<Stake, Reward>(
    farm: &InterestFarm<Stake>,
    expected_rewards: u64,
    expected_rewards_per_second: u64,
    expected_last_reward_timestamp: u64,
    expected_accrued_rewards_per_share: u256,
) {
    let (
        rewards,
        rewards_per_second,
        last_reward_timestamp,
        accrued_rewards_per_share,
    ) = interest_farm::reward_data<Stake, Reward>(farm);

    assert_eq(rewards, expected_rewards);
    assert_eq(rewards_per_second, expected_rewards_per_second);
    assert_eq(last_reward_timestamp, expected_last_reward_timestamp);
    assert_eq(accrued_rewards_per_share, expected_accrued_rewards_per_share);
}

fun increase_seconds(clock: &mut Clock, seconds: u64) {
    clock.increment_for_testing(seconds * 1_000);
}

use fun increase_seconds as Clock.increase_seconds;
use fun assert_reward_data as InterestFarm.assert_reward_data;
