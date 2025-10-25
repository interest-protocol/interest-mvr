// #[test_only, allow(unused_const, unused_let_mut, unused_mut_ref)]
// module interest_farms::interest_farm_tests;

// use interest_access_control::access_control::{Self, AdminWitness};
// use interest_farms::{interest_farm::{Self, InterestFarm}, interest_farm_errors, ipx::{Self, IPX}};
// use std::type_name;
// use sui::{
//     clock::{Self, Clock},
//     coin::{mint_for_testing, CoinMetadata},
//     sui::SUI,
//     test_scenario::{Self as ts, Scenario},
//     test_utils::{destroy, assert_eq}
// };

// const ADMIN: address = @0x1;

// const ALICE: address = @0x2;

// const BOB: address = @0x3;

// const POW_10_9: u64 = 1_000_000_000;

// const POW_10_6: u64 = 1_000_000;

// public struct Test() has drop;

// public struct USDC() has drop;

// const DEFAULT_USDC_REWARDS_PER_SECOND: u64 = 10  * POW_10_6;

// const DEFAULT_SUI_REWARDS_PER_SECOND: u64 = 2 * POW_10_9;

// const DEFAULT_USDC_REWARDS: u64 = 3_500 * POW_10_9;

// const DEFAULT_SUI_REWARDS: u64 = 1_000 * POW_10_9;

// const PRECISION: u256 = 1__000_000_000;

// public struct Dapp {
//     clock: Option<Clock>,
//     admin_witness: Option<AdminWitness<Test>>,
//     scenario: Option<Scenario>,
//     ipx_metadata: Option<CoinMetadata<IPX>>,
//     farm: Option<InterestFarm<IPX>>,
// }

// #[test]
// fun test_new_farm() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.env!(|clock, admin_witness, ipx_metadata, scenario| {
//         let start_time = 100;

//         let mut new_request_farm = interest_farm::request_new_farm<IPX, Test>(
//             clock,
//             ipx_metadata,
//             admin_witness,
//             start_time,
//             scenario.ctx(),
//         );

//         new_request_farm.register_reward<IPX, SUI>(scenario.ctx());
//         new_request_farm.register_reward<IPX, USDC>(scenario.ctx());

//         let mut farm = new_request_farm.new_farm<IPX>(scenario.ctx());

//         assert_eq(
//             interest_farm::rewards<IPX>(&farm),
//             vector[type_name::get<SUI>(), type_name::get<USDC>()],
//         );

//         farm.assert_reward_data<IPX, SUI>(0, 0, 0, 0);
//         farm.assert_reward_data<IPX, USDC>(0, 0, 0, 0);

//         assert_eq(interest_farm::total_stake_amount<IPX>(&farm), 0);
//         assert_eq(
//             interest_farm::precision<IPX>(&farm),
//             10u256.pow(ipx_metadata.get_decimals()) * interest_farms::interest_farm_constants::pow_10_9!(),
//         );
//         assert_eq(interest_farm::start_timestamp<IPX>(&farm), start_time);
//         assert_eq(interest_farm::paused<IPX>(&farm), false);

//         clock.increase_seconds(1_000);

//         farm.set_rewards_per_second<IPX, SUI, Test>(clock, admin_witness, 1_000);
//         farm.add_reward<IPX, SUI>(clock, mint_for_testing(1_000 * POW_10_9, scenario.ctx()));

//         farm.assert_reward_data<IPX, SUI>(1_000 * POW_10_9, 1_000, 1_000, 0);

//         clock.increase_seconds(500);

//         farm.set_rewards_per_second<IPX, USDC, Test>(clock, admin_witness, 2_000);
//         farm.add_reward<IPX, USDC>(clock, mint_for_testing(3_500 * POW_10_9, scenario.ctx()));

//         assert_eq(farm.balance_value<IPX, USDC>(), 3_500 * POW_10_9);
//         assert_eq(farm.balance_value<IPX, SUI>(), 1_000 * POW_10_9);

//         farm.assert_reward_data<IPX, USDC>(3_500 * POW_10_9, 2_000, 1_500, 0);

//         destroy(farm);
//     });

//     dapp.end();
// }

// #[test]
// fun test_new_account() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, _clock, _admin_witness, _ipx_metadata, scenario| {
//         let account = farm.new_account<IPX>(scenario.ctx());

//         account.assert_belongs_to_farm_for_test(farm);

//         assert_eq(account.account_balance(), 0);
//         assert_eq(account.account_reward_debts<IPX, SUI>(), 0);
//         assert_eq(account.account_reward_debts<IPX, USDC>(), 0);
//         assert_eq(account.account_rewards<IPX, SUI>(), 0);
//         assert_eq(account.account_rewards<IPX, USDC>(), 0);

//         account.destroy_account();
//     });
//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EInvalidTimestamp,
//         location = interest_farm,
//     ),
// ]
// fun test_new_farm_invalid_start_timestamp() {
//     let mut dapp = deploy();

//     dapp.env!(|clock, _admin_witness, _ipx_metadata, _scenario| {
//         clock.increase_seconds(1);
//     });

//     dapp.add_default_farm(0);

//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EMissingRewards,
//         location = interest_farm,
//     ),
// ]
// fun test_new_no_rewards() {
//     let mut dapp = deploy();

//     dapp.env!(|clock, admin_witness, ipx_metadata, scenario| {
//         let mut new_request_farm = interest_farm::request_new_farm<IPX, Test>(
//             clock,
//             ipx_metadata,
//             admin_witness,
//             0,
//             scenario.ctx(),
//         );

//         let farm = new_request_farm.new_farm<IPX>(scenario.ctx());

//         destroy(farm);
//     });

//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EFarmIsPaused,
//         location = interest_farm,
//     ),
// ]
// fun test_new_account_farm_paused() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, _clock, admin_witness, _ipx_metadata, scenario| {
//         farm.pause<IPX, Test>(admin_witness);

//         let account = farm.new_account<IPX>(scenario.ctx());

//         account.assert_belongs_to_farm_for_test(farm);

//         assert_eq(account.account_balance(), 0);
//         assert_eq(account.account_reward_debts<IPX, SUI>(), 0);
//         assert_eq(account.account_reward_debts<IPX, USDC>(), 0);
//         assert_eq(account.account_rewards<IPX, SUI>(), 0);
//         assert_eq(account.account_rewards<IPX, USDC>(), 0);

//         account.destroy_account();
//     });
//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EFarmIsPaused,
//         location = interest_farm,
//     ),
// ]
// fun test_stake_farm_paused() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, admin_witness, _ipx_metadata, scenario| {
//         let mut account = farm.new_account<IPX>(scenario.ctx());

//         farm.pause<IPX, Test>(admin_witness);

//         account.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(10 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         destroy(account);
//     });
//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EAccountAndFarmMismatch,
//         location = interest_farm,
//     ),
// ]
// fun test_stake_with_invalid_account() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account = interest_farm::new_invalid_account_for_test<IPX>(scenario.ctx());

//         account.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(10 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         destroy(account);
//     });
//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EAccountAndFarmMismatch,
//         location = interest_farm,
//     ),
// ]
// fun test_unstake_with_invalid_account() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account = interest_farm::new_invalid_account_for_test<IPX>(scenario.ctx());

//         account
//             .unstake<IPX>(
//                 farm,
//                 clock,
//                 10 * POW_10_9,
//                 scenario.ctx(),
//             )
//             .burn_for_testing();

//         destroy(account);
//     });
//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EFarmIsPaused,
//         location = interest_farm,
//     ),
// ]
// fun test_harvest_farm_paused() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, admin_witness, _ipx_metadata, scenario| {
//         let mut account = farm.new_account<IPX>(scenario.ctx());

//         farm.pause<IPX, Test>(admin_witness);

//         account
//             .harvest<IPX, SUI>(
//                 farm,
//                 clock,
//                 scenario.ctx(),
//             )
//             .burn_for_testing();

//         destroy(account);
//     });
//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EAccountAndFarmMismatch,
//         location = interest_farm,
//     ),
// ]
// fun test_harvest_with_invalid_account() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account = interest_farm::new_invalid_account_for_test<IPX>(scenario.ctx());

//         account
//             .harvest<IPX, SUI>(
//                 farm,
//                 clock,
//                 scenario.ctx(),
//             )
//             .burn_for_testing();

//         destroy(account);
//     });
//     dapp.end();
// }

// #[test, expected_failure(abort_code = interest_farm_errors::EZeroRewards, location = interest_farm)]
// fun test_harvest_zero_rewards() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account = farm.new_account<IPX>(scenario.ctx());

//         account
//             .harvest<IPX, SUI>(
//                 farm,
//                 clock,
//                 scenario.ctx(),
//             )
//             .burn_for_testing();

//         destroy(account);
//     });

//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::ENonZeroRewards,
//         location = interest_farm,
//     ),
// ]
// fun test_destroy_account_with_rewards() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account = farm.new_account<IPX>(scenario.ctx());

//         account.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(10 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         clock.increase_seconds(10);

//         account.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(0, scenario.ctx()),
//             scenario.ctx(),
//         );

//         account.destroy();
//     });

//     dapp.end();
// }

// #[test]
// fun test_pause_and_unpause_farm() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, _clock, admin_witness, _ipx_metadata, _scenario| {
//         farm.pause<IPX, Test>(admin_witness);

//         assert_eq(farm.paused<IPX>(), true);

//         farm.unpause<IPX, Test>(admin_witness);

//         assert_eq(farm.paused<IPX>(), false);
//     });

//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EInvalidAdmin,
//         location = interest_farm,
//     ),
// ]
// fun test_pause_invalid_admin() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, _clock, _admin_witness, _ipx_metadata, _scenario| {
//         let invalid_admin_witness = access_control::sign_in_for_testing<USDC>(1);

//         farm.pause<IPX, USDC>(&invalid_admin_witness);
//     });

//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EInvalidAdmin,
//         location = interest_farm,
//     ),
// ]
// fun test_unpause_invalid_admin() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, _clock, _admin_witness, _ipx_metadata, _scenario| {
//         let invalid_admin_witness = access_control::sign_in_for_testing<USDC>(1);

//         farm.unpause<IPX, USDC>(&invalid_admin_witness);
//     });

//     dapp.end();
// }

// #[
//     test,
//     expected_failure(
//         abort_code = interest_farm_errors::EInvalidAdmin,
//         location = interest_farm,
//     ),
// ]
// fun test_set_rewards_per_second_invalid_admin() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, _scenario| {
//         let invalid_admin_witness = access_control::sign_in_for_testing<USDC>(1);

//         farm.set_rewards_per_second<IPX, SUI, USDC>(clock, &invalid_admin_witness, 1_000);
//     });

//     dapp.end();
// }

// #[test]
// fun test_stake() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account1 = farm.new_account<IPX>(scenario.ctx());
//         let mut account2 = farm.new_account<IPX>(scenario.ctx());

//         assert_eq(farm.total_stake_amount<IPX>(), 0);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(10 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         assert_eq(farm.total_stake_amount<IPX>(), 10 * POW_10_9);
//         assert_eq(account1.account_balance(), 10 * POW_10_9);
//         assert_eq(account1.account_reward_debts<IPX, SUI>(), 0);
//         assert_eq(account1.account_reward_debts<IPX, USDC>(), 0);
//         assert_eq(account1.account_rewards<IPX, SUI>(), 0);
//         assert_eq(account1.account_rewards<IPX, USDC>(), 0);

//         farm.assert_reward_data<IPX, SUI>(
//             DEFAULT_SUI_REWARDS,
//             DEFAULT_SUI_REWARDS_PER_SECOND,
//             0,
//             0,
//         );
//         farm.assert_reward_data<IPX, USDC>(
//             DEFAULT_USDC_REWARDS,
//             DEFAULT_USDC_REWARDS_PER_SECOND,
//             0,
//             0,
//         );

//         clock.increase_seconds(10);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(5 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let sui_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, SUI>();
//         let usdc_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, USDC>();

//         // 10 seconds
//         assert_eq(
//             sui_accrued_rewards_per_share,
//             (DEFAULT_SUI_REWARDS_PER_SECOND as u256) * 10 * (POW_10_9 as u256) * PRECISION / (10 * POW_10_9 as u256),
//         );

//         assert_eq(
//             usdc_accrued_rewards_per_share,
//             (DEFAULT_USDC_REWARDS_PER_SECOND as u256) * 10 * (POW_10_9 as u256) * PRECISION / (10 * POW_10_9 as u256),
//         );

//         assert_eq(
//             account1.account_reward_debts<IPX, SUI>(),
//             15 * sui_accrued_rewards_per_share / PRECISION,
//         );
//         assert_eq(
//             account1.account_reward_debts<IPX, USDC>(),
//             15 * usdc_accrued_rewards_per_share / PRECISION,
//         );
//         assert_eq(account1.account_rewards<IPX, SUI>(), 10 * DEFAULT_SUI_REWARDS_PER_SECOND);
//         assert_eq(account1.account_rewards<IPX, USDC>(), 10 * DEFAULT_USDC_REWARDS_PER_SECOND);
//         assert_eq(account1.account_balance(), 15 * POW_10_9);

//         clock.increase_seconds(5);

//         account2.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(20 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let sui_accrued_rewards_per_share2 = farm.accrued_rewards_per_share<IPX, SUI>();
//         let usdc_accrued_rewards_per_share2 = farm.accrued_rewards_per_share<IPX, USDC>();

//         let expected_sui_accrued_rewards_per_share =
//             sui_accrued_rewards_per_share + ((DEFAULT_SUI_REWARDS_PER_SECOND as u256) * 5 * (POW_10_9 as u256) * PRECISION / (15 * POW_10_9 as u256));
//         let expected_usdc_accrued_rewards_per_share =
//             usdc_accrued_rewards_per_share + ((DEFAULT_USDC_REWARDS_PER_SECOND as u256) * 5 * (POW_10_9 as u256) * PRECISION / (15 * POW_10_9 as u256));

//         assert_eq(sui_accrued_rewards_per_share2, expected_sui_accrued_rewards_per_share);
//         assert_eq(usdc_accrued_rewards_per_share2, expected_usdc_accrued_rewards_per_share);

//         assert_eq(
//             account2.account_reward_debts<IPX, SUI>(),
//             20 * sui_accrued_rewards_per_share2 / PRECISION,
//         );
//         assert_eq(
//             account2.account_reward_debts<IPX, USDC>(),
//             20 * usdc_accrued_rewards_per_share2 / PRECISION,
//         );
//         assert_eq(account2.account_rewards<IPX, SUI>(), 0);
//         assert_eq(account2.account_rewards<IPX, USDC>(), 0);
//         assert_eq(account2.account_balance(), 20 * POW_10_9);

//         destroy(account1);
//         destroy(account2);
//     });

//     dapp.end();
// }

// #[test]
// fun test_unstake() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account1 = farm.new_account<IPX>(scenario.ctx());
//         let mut account2 = farm.new_account<IPX>(scenario.ctx());

//         assert_eq(farm.total_stake_amount<IPX>(), 0);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(10 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         clock.increase_seconds(7);

//         let removed_coin = account1.unstake<IPX>(
//             farm,
//             clock,
//             7 * POW_10_9,
//             scenario.ctx(),
//         );

//         assert_eq(removed_coin.burn_for_testing(), 7 * POW_10_9);

//         let sui_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, SUI>();
//         let usdc_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, USDC>();

//         assert_eq(
//             account1.account_rewards<IPX, SUI>(),
//             DEFAULT_SUI_REWARDS_PER_SECOND * 7,
//         );
//         assert_eq(
//             account1.account_rewards<IPX, USDC>(),
//             DEFAULT_USDC_REWARDS_PER_SECOND * 7,
//         );
//         assert_eq(
//             account1.account_reward_debts<IPX, SUI>(),
//             sui_accrued_rewards_per_share * 3 / PRECISION,
//         );
//         assert_eq(
//             account1.account_reward_debts<IPX, USDC>(),
//             usdc_accrued_rewards_per_share * 3 / PRECISION,
//         );
//         assert_eq(
//             account1.account_balance(),
//             3 * POW_10_9,
//         );

//         account2.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(8 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         assert_eq(
//             account2.account_rewards<IPX, SUI>(),
//             0,
//         );
//         assert_eq(
//             account2.account_rewards<IPX, USDC>(),
//             0,
//         );
//         assert_eq(
//             account2.account_reward_debts<IPX, SUI>(),
//             sui_accrued_rewards_per_share * 8 / PRECISION,
//         );
//         assert_eq(
//             account2.account_reward_debts<IPX, USDC>(),
//             usdc_accrued_rewards_per_share * 8 / PRECISION,
//         );
//         assert_eq(
//             account2.account_balance(),
//             8 * POW_10_9,
//         );

//         clock.increase_seconds(7);

//         let removed_coin2 = account2.unstake<IPX>(
//             farm,
//             clock,
//             8 * POW_10_9,
//             scenario.ctx(),
//         );

//         assert_eq(removed_coin2.burn_for_testing(), 8 * POW_10_9);

//         assert_eq(
//             account2.account_rewards<IPX, SUI>(),
//             DEFAULT_SUI_REWARDS_PER_SECOND * 8 * 7 / 11,
//         );
//         assert_eq(
//             account2.account_rewards<IPX, USDC>(),
//             DEFAULT_USDC_REWARDS_PER_SECOND * 8 * 7 / 11,
//         );
//         assert_eq(
//             account2.account_reward_debts<IPX, SUI>(),
//             0,
//         );
//         assert_eq(
//             account2.account_reward_debts<IPX, USDC>(),
//             0,
//         );
//         assert_eq(
//             account2.account_balance(),
//             0,
//         );

//         destroy(account1);
//         destroy(account2);
//     });

//     dapp.end();
// }

// #[test]
// fun test_harvest() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account1 = farm.new_account<IPX>(scenario.ctx());

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(10 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         assert_eq(farm.total_stake_amount<IPX>(), 10 * POW_10_9);
//         assert_eq(account1.account_balance(), 10 * POW_10_9);
//         assert_eq(account1.account_reward_debts<IPX, SUI>(), 0);
//         assert_eq(account1.account_reward_debts<IPX, USDC>(), 0);
//         assert_eq(account1.account_rewards<IPX, SUI>(), 0);
//         assert_eq(account1.account_rewards<IPX, USDC>(), 0);

//         let sui_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, SUI>();
//         let usdc_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, USDC>();

//         assert_eq(
//             sui_accrued_rewards_per_share,
//             0,
//         );
//         assert_eq(
//             usdc_accrued_rewards_per_share,
//             0,
//         );

//         clock.increase_seconds(12);

//         let sui_rewards = account1.harvest<IPX, SUI>(farm, clock, scenario.ctx());
//         let usdc_rewards = account1.harvest<IPX, USDC>(farm, clock, scenario.ctx());

//         assert_eq(sui_rewards.burn_for_testing(), 12 * DEFAULT_SUI_REWARDS_PER_SECOND);
//         assert_eq(usdc_rewards.burn_for_testing(), 12 * DEFAULT_USDC_REWARDS_PER_SECOND);

//         let sui_accrued_rewards_per_share2 = farm.accrued_rewards_per_share<IPX, SUI>();
//         let usdc_accrued_rewards_per_share2 = farm.accrued_rewards_per_share<IPX, USDC>();

//         assert_eq(farm.total_stake_amount<IPX>(), 10 * POW_10_9);
//         assert_eq(account1.account_balance(), 10 * POW_10_9);
//         assert_eq(
//             account1.account_reward_debts<IPX, SUI>(),
//             sui_accrued_rewards_per_share2 * 10 / PRECISION,
//         );
//         assert_eq(
//             account1.account_reward_debts<IPX, USDC>(),
//             usdc_accrued_rewards_per_share2 * 10 / PRECISION,
//         );
//         assert_eq(account1.account_rewards<IPX, SUI>(), 0);
//         assert_eq(account1.account_rewards<IPX, USDC>(), 0);

//         destroy(account1);
//     });

//     dapp.end();
// }

// #[test]
// fun test_calculations() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account1 = farm.new_account<IPX>(scenario.ctx());
//         let mut account2 = farm.new_account<IPX>(scenario.ctx());

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(6 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let sui_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, SUI>();
//         let usdc_accrued_rewards_per_share = farm.accrued_rewards_per_share<IPX, USDC>();

//         assert_eq(sui_accrued_rewards_per_share, 0);
//         assert_eq(usdc_accrued_rewards_per_share, 0);

//         clock.increase_seconds(12);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(4 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         account2.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(6 * POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let pending_sui_rewards = account1.pending_rewards_for_test<IPX, SUI>(farm, clock);

//         let sui_accrued_rewards_per_share =
//             sui_accrued_rewards_per_share + (
//             (DEFAULT_SUI_REWARDS_PER_SECOND as u256) * 12 * (POW_10_9 as u256) * PRECISION / (6 * POW_10_9 as u256)
//         );

//         assert_eq(pending_sui_rewards, DEFAULT_SUI_REWARDS_PER_SECOND * 12);

//         clock.increase_seconds(12);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let sui_accrued_rewards_per_share2 =
//             sui_accrued_rewards_per_share + ((DEFAULT_SUI_REWARDS_PER_SECOND as u256) * 12 * (POW_10_9 as u256) * PRECISION / (16 * POW_10_9 as u256));

//         assert_eq(farm.accrued_rewards_per_share<IPX, SUI>(), sui_accrued_rewards_per_share2);
//         assert_eq(
//             account1.account_reward_debts<IPX, SUI>(),
//             sui_accrued_rewards_per_share2 * 11 / PRECISION,
//         );

//         destroy(account1);
//         destroy(account2);
//     });

//     dapp.end();
// }

// #[test]
// fun test_rewards_tracking() {
//     let mut dapp = deploy();

//     dapp.add_default_farm(0);

//     dapp.farm_env!(|farm, clock, _admin_witness, _ipx_metadata, scenario| {
//         let mut account1 = farm.new_account<IPX>(scenario.ctx());

//         let sui_rewards = farm.rewards<IPX, SUI>();
//         let usdc_rewards = farm.rewards<IPX, USDC>();

//         assert_eq(sui_rewards, DEFAULT_SUI_REWARDS);
//         assert_eq(usdc_rewards, DEFAULT_USDC_REWARDS);

//         clock.increase_seconds(10);

//         let sui_rewards = farm.rewards<IPX, SUI>();
//         let usdc_rewards = farm.rewards<IPX, USDC>();

//         assert_eq(sui_rewards, DEFAULT_SUI_REWARDS);
//         assert_eq(usdc_rewards, DEFAULT_USDC_REWARDS);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         clock.increase_seconds(10);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let sui_rewards = farm.rewards<IPX, SUI>();
//         let usdc_rewards = farm.rewards<IPX, USDC>();

//         assert_eq(sui_rewards, DEFAULT_SUI_REWARDS - DEFAULT_SUI_REWARDS_PER_SECOND * 10);
//         assert_eq(usdc_rewards, DEFAULT_USDC_REWARDS - DEFAULT_USDC_REWARDS_PER_SECOND * 10);

//         assert_eq(farm.balance_value<IPX, SUI>(), DEFAULT_SUI_REWARDS);
//         assert_eq(farm.balance_value<IPX, USDC>(), DEFAULT_USDC_REWARDS);

//         clock.increase_seconds(POW_10_9);

//         account1.stake<IPX>(
//             farm,
//             clock,
//             mint_for_testing(POW_10_9, scenario.ctx()),
//             scenario.ctx(),
//         );

//         let sui_rewards = farm.rewards<IPX, SUI>();
//         let usdc_rewards = farm.rewards<IPX, USDC>();

//         assert_eq(sui_rewards, 0);
//         assert_eq(usdc_rewards, 0);

//         assert_eq(farm.balance_value<IPX, SUI>(), DEFAULT_SUI_REWARDS);
//         assert_eq(farm.balance_value<IPX, USDC>(), DEFAULT_USDC_REWARDS);

//         destroy(account1);
//     });

//     dapp.end();
// }

// macro fun farm_env(
//     $dapp: &mut Dapp,
//     $fn: |
//         &mut InterestFarm<IPX>,
//         &mut Clock,
//         &mut AdminWitness<Test>,
//         &mut CoinMetadata<IPX>,
//         &mut Scenario,
//     |,
// ) {
//     let mut dapp = $dapp;

//     let mut clock = dapp.clock.extract();
//     let mut admin_witness = dapp.admin_witness.extract();
//     let mut scenario = dapp.scenario.extract();
//     let mut ipx_metadata = dapp.ipx_metadata.extract();
//     let mut farm = dapp.farm.extract();

//     $fn(&mut farm, &mut clock, &mut admin_witness, &mut ipx_metadata, &mut scenario);

//     dapp.clock.fill(clock);
//     dapp.admin_witness.fill(admin_witness);
//     dapp.scenario.fill(scenario);
//     dapp.ipx_metadata.fill(ipx_metadata);
//     dapp.farm.fill(farm);
// }

// macro fun env(
//     $dapp: &mut Dapp,
//     $fn: |&mut Clock, &mut AdminWitness<Test>, &mut CoinMetadata<IPX>, &mut Scenario|,
// ) {
//     let mut dapp = $dapp;

//     let mut clock = dapp.clock.extract();
//     let mut admin_witness = dapp.admin_witness.extract();
//     let mut scenario = dapp.scenario.extract();
//     let mut ipx_metadata = dapp.ipx_metadata.extract();

//     $fn(&mut clock, &mut admin_witness, &mut ipx_metadata, &mut scenario);

//     dapp.clock.fill(clock);
//     dapp.admin_witness.fill(admin_witness);
//     dapp.scenario.fill(scenario);
//     dapp.ipx_metadata.fill(ipx_metadata);
// }

// fun add_default_farm(dapp: &mut Dapp, start_time: u64) {
//     let clock = dapp.clock.borrow_mut();
//     let admin_witness = dapp.admin_witness.borrow_mut();
//     let scenario = dapp.scenario.borrow_mut();
//     let ipx_metadata = dapp.ipx_metadata.borrow_mut();

//     let mut new_request_farm = interest_farm::request_new_farm<IPX, Test>(
//         clock,
//         ipx_metadata,
//         admin_witness,
//         start_time,
//         scenario.ctx(),
//     );

//     new_request_farm.register_reward<IPX, SUI>(scenario.ctx());
//     new_request_farm.register_reward<IPX, USDC>(scenario.ctx());

//     let mut farm = new_request_farm.new_farm<IPX>(scenario.ctx());

//     farm.set_rewards_per_second<IPX, SUI, Test>(
//         clock,
//         admin_witness,
//         DEFAULT_SUI_REWARDS_PER_SECOND,
//     );
//     farm.add_reward<IPX, SUI>(clock, mint_for_testing(DEFAULT_SUI_REWARDS, scenario.ctx()));

//     farm.set_rewards_per_second<IPX, USDC, Test>(
//         clock,
//         admin_witness,
//         DEFAULT_USDC_REWARDS_PER_SECOND,
//     );
//     farm.add_reward<IPX, USDC>(clock, mint_for_testing(DEFAULT_USDC_REWARDS, scenario.ctx()));

//     dapp.farm.fill(farm);
// }

// fun deploy(): Dapp {
//     let mut scenario = ts::begin(ADMIN);

//     ipx::init_for_testing(scenario.ctx());

//     scenario.next_tx(ADMIN);

//     let ipx_metadata = scenario.take_shared<CoinMetadata<IPX>>();

//     let clock = clock::create_for_testing(scenario.ctx());

//     let admin_witness = access_control::sign_in_for_testing<Test>(0);

//     Dapp {
//         clock: option::some(clock),
//         admin_witness: option::some(admin_witness),
//         scenario: option::some(scenario),
//         ipx_metadata: option::some(ipx_metadata),
//         farm: option::none(),
//     }
// }

// fun end(dapp: Dapp) {
//     destroy(dapp);
// }

// fun accrued_rewards_per_share<Stake, Reward>(farm: &InterestFarm<Stake>): u256 {
//     let (_, _, _, accrued_rewards_per_share) = interest_farm::reward_data<Stake, Reward>(farm);

//     accrued_rewards_per_share
// }

// fun rewards<Stake, Reward>(farm: &InterestFarm<Stake>): u64 {
//     let (rewards, _, _, _) = interest_farm::reward_data<Stake, Reward>(farm);

//     rewards
// }

// fun assert_reward_data<Stake, Reward>(
//     farm: &InterestFarm<Stake>,
//     expected_rewards: u64,
//     expected_rewards_per_second: u64,
//     expected_last_reward_timestamp: u64,
//     expected_accrued_rewards_per_share: u256,
// ) {
//     let (
//         rewards,
//         rewards_per_second,
//         last_reward_timestamp,
//         accrued_rewards_per_share,
//     ) = interest_farm::reward_data<Stake, Reward>(farm);

//     assert_eq(rewards, expected_rewards);
//     assert_eq(rewards_per_second, expected_rewards_per_second);
//     assert_eq(last_reward_timestamp, expected_last_reward_timestamp);
//     assert_eq(accrued_rewards_per_share, expected_accrued_rewards_per_share);
// }

// fun increase_seconds(clock: &mut Clock, seconds: u64) {
//     clock.increment_for_testing(seconds * 1_000);
// }

// use fun rewards as InterestFarm.rewards;
// use fun increase_seconds as Clock.increase_seconds;
// use fun assert_reward_data as InterestFarm.assert_reward_data;
// use fun accrued_rewards_per_share as InterestFarm.accrued_rewards_per_share;
