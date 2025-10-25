module interest_farms::interest_farm;

use interest_access_control::access_control::AdminWitness;
use interest_farms::interest_farm_events;
use std::type_name::{Self, TypeName};
use sui::{
    balance::{Self, Balance},
    clock::Clock,
    coin::{CoinMetadata, Coin},
    coin_registry::Currency,
    dynamic_field as df,
    vec_map::{Self, VecMap}
};

// === Structs ===

public struct RewardBalance(TypeName) has copy, drop, store;

public struct Decimals(u8) has copy, drop, store;

public struct RewardData has copy, drop, store {
    /// Seconds
    end: u64,
    rewards: u64,
    rewards_per_second: u64,
    last_reward_timestamp: u64,
    accrued_rewards_per_share: u256,
}

public struct InterestFarmAccount<phantom Stake> has key, store {
    id: UID,
    farm: address,
    balance: Balance<Stake>,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
}

public struct NewFarmRequest<phantom Stake> {
    farm: InterestFarm<Stake>,
}

public struct InterestFarm<phantom Stake> has key, store {
    id: UID,
    rewards: vector<TypeName>,
    reward_data: VecMap<TypeName, RewardData>,
    total_stake_amount: u64,
    precision: u256,
    paused: bool,
    admin_type: TypeName,
}

// === Public Mutative Functions ===

public fun new_account<Stake>(
    farm: &InterestFarm<Stake>,
    ctx: &mut TxContext,
): InterestFarmAccount<Stake> {
    farm.assert_is_live();
    let account = InterestFarmAccount {
        id: object::new(ctx),
        farm: farm.id.to_address(),
        balance: balance::zero(),
        reward_debts: farm.rewards.fold!(vec_map::empty(), |mut acc, reward_name| {
            acc.insert(reward_name, 0);

            acc
        }),
        rewards: farm.rewards.fold!(vec_map::empty(), |mut acc, reward_name| {
            acc.insert(reward_name, 0);

            acc
        }),
    };

    interest_farm_events::emit_new_account(farm.id.to_address(), account.id.to_address());

    account
}

public fun destroy_account<Stake>(account: InterestFarmAccount<Stake>) {
    let InterestFarmAccount { id, farm: _, balance, reward_debts: _, rewards } = account;

    let (_, values) = rewards.into_keys_values();

    assert!(
        values.all!(|value| value == 0),
        interest_farms::interest_farm_errors::non_zero_rewards!(),
    );

    interest_farm_events::emit_destroy_account(id.to_address());

    balance.destroy_zero();
    id.delete();
}

public fun stake<Stake>(
    account: &mut InterestFarmAccount<Stake>,
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    deposit: Coin<Stake>,
    _ctx: &mut TxContext,
) {
    farm.assert_is_live();
    account.assert_belongs_to_farm(farm);

    farm.update_with_account(clock, account);

    let deposit_value = deposit.value();

    account.balance.join(deposit.into_balance());

    account.update_reward_debt(farm);

    farm.total_stake_amount = farm.total_stake_amount + deposit_value;

    interest_farm_events::emit_stake(
        farm.id.to_address(),
        account.id.to_address(),
        deposit_value,
        farm.total_stake_amount,
        type_name::with_defining_ids<Stake>(),
    );
}

public fun unstake<Stake>(
    account: &mut InterestFarmAccount<Stake>,
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    amount: u64,
    ctx: &mut TxContext,
): Coin<Stake> {
    account.assert_belongs_to_farm(farm);

    farm.update_with_account(clock, account);

    let unstake_coin = account.balance.split(amount).into_coin(ctx);

    account.update_reward_debt(farm);

    farm.total_stake_amount = farm.total_stake_amount - amount;

    interest_farm_events::emit_unstake(
        farm.id.to_address(),
        account.id.to_address(),
        amount,
        farm.total_stake_amount,
        type_name::with_defining_ids<Stake>(),
    );

    unstake_coin
}

public fun harvest<Stake, Reward>(
    account: &mut InterestFarmAccount<Stake>,
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    ctx: &mut TxContext,
): Coin<Reward> {
    farm.assert_is_live();
    account.assert_belongs_to_farm(farm);

    farm.update_with_account(clock, account);

    account.update_reward_debt(farm);

    let reward_name = type_name::with_defining_ids<Reward>();

    let account_reward = &mut account.rewards[&reward_name];

    let rewards_to_withdraw = *account_reward;

    assert!(rewards_to_withdraw != 0, interest_farms::interest_farm_errors::zero_rewards!());

    *account_reward = 0;

    let reward_balance = farm.balance_mut(reward_name);

    let balance_available = reward_balance.value();

    let reward_coin = reward_balance
        .split(rewards_to_withdraw.min(balance_available))
        .into_coin(ctx);

    interest_farm_events::emit_harvest(
        farm.id.to_address(),
        account.id.to_address(),
        reward_coin.value(),
        reward_name,
    );

    reward_coin
}

public fun add_reward<Stake, Reward>(
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    reward: Coin<Reward>,
) {
    let reward_name = type_name::with_defining_ids<Reward>();

    farm.update(clock);

    let farm_reward_data = &mut farm.reward_data[&reward_name];

    let reward_amount = reward.value();

    farm_reward_data.rewards = farm_reward_data.rewards + reward_amount;

    interest_farm_events::emit_add_reward(farm.id.to_address(), reward_name, reward_amount);

    farm.balance_mut(reward_name).join(reward.into_balance());
}

// === Utility Functions ===

public fun coin_metadata_decimals<Stake>(coin_metadata: &CoinMetadata<Stake>): Decimals {
    Decimals(coin_metadata.get_decimals())
}

public fun currency_decimals<Stake>(currency: &Currency<Stake>): Decimals {
    Decimals(currency.decimals())
}

// === Admin Functions ===

public fun request_new_farm<Stake, Admin>(
    decimals: Decimals,
    _: &AdminWitness<Admin>,
    ctx: &mut TxContext,
): NewFarmRequest<Stake> {
    let farm = InterestFarm<Stake> {
        id: object::new(ctx),
        rewards: vector[],
        reward_data: vec_map::empty(),
        total_stake_amount: 0,
        precision: 10u256.pow(decimals.0) * interest_farms::interest_farm_constants::pow_10_9!(),
        paused: false,
        admin_type: type_name::with_defining_ids<Admin>(),
    };

    NewFarmRequest {
        farm,
    }
}

public fun register_reward<Stake, Reward>(
    request: &mut NewFarmRequest<Stake>,
    _ctx: &mut TxContext,
) {
    let reward_name = type_name::with_defining_ids<Reward>();

    df::add<RewardBalance, Balance<Reward>>(
        &mut request.farm.id,
        RewardBalance(reward_name),
        balance::zero(),
    );

    request.farm.rewards.push_back(reward_name);

    request.farm.reward_data.insert(reward_name, default_reward_data());
}

public fun new_farm<Stake>(
    request: NewFarmRequest<Stake>,
    _ctx: &mut TxContext,
): InterestFarm<Stake> {
    let NewFarmRequest { farm } = request;

    assert!(farm.rewards.length() != 0, interest_farms::interest_farm_errors::missing_rewards!());

    interest_farm_events::emit_new_farm(farm.id.to_address(), farm.rewards, farm.admin_type);

    farm
}

public fun set_end_time<Stake, Reward, Admin>(
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    _: &AdminWitness<Admin>,
    end: u64,
) {
    farm.assert_is_admin<_, Admin>();

    farm.update(clock);

    assert!(end > clock.now(), interest_farms::interest_farm_errors::invalid_end_timestamp!());

    let farm_reward_data = &mut farm.reward_data[&type_name::with_defining_ids<Reward>()];
    farm_reward_data.end = end;

    interest_farm_events::emit_set_end_time(
        farm.id.to_address(),
        type_name::with_defining_ids<Reward>(),
        end,
    );
}

public fun set_rewards_per_second<Stake, Reward, Admin>(
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    _: &AdminWitness<Admin>,
    new_rewards_per_second: u64,
) {
    farm.assert_is_admin<_, Admin>();

    farm.update(clock);

    let farm_reward_data = &mut farm.reward_data[&type_name::with_defining_ids<Reward>()];
    farm_reward_data.rewards_per_second = new_rewards_per_second;

    interest_farm_events::emit_set_rewards_per_second(
        farm.id.to_address(),
        type_name::with_defining_ids<Reward>(),
        farm_reward_data.rewards_per_second,
        new_rewards_per_second,
    );
}

public fun pause<Stake, Admin>(farm: &mut InterestFarm<Stake>, _: &AdminWitness<Admin>) {
    farm.assert_is_admin<_, Admin>();

    farm.paused = true;
}

public fun unpause<Stake, Admin>(farm: &mut InterestFarm<Stake>, _: &AdminWitness<Admin>) {
    farm.assert_is_admin<_, Admin>();

    farm.paused = false;
}

// === Private Functions ===

fun assert_is_live<Stake>(farm: &InterestFarm<Stake>) {
    assert!(!farm.paused, interest_farms::interest_farm_errors::farm_is_paused!());
}

fun assert_is_admin<Stake, Admin>(farm: &InterestFarm<Stake>) {
    assert!(
        farm.admin_type == type_name::with_defining_ids<Admin>(),
        interest_farms::interest_farm_errors::invalid_admin!(),
    );
}

fun assert_belongs_to_farm<Stake>(
    account: &InterestFarmAccount<Stake>,
    farm: &InterestFarm<Stake>,
) {
    assert!(
        farm.id.to_address() == account.farm,
        interest_farms::interest_farm_errors::account_and_farm_mismatch!(),
    );
}

#[allow(unused_function)]
fun pending_rewards<Stake, Reward>(
    account: &InterestFarmAccount<Stake>,
    farm: &InterestFarm<Stake>,
    clock: &Clock,
): u64 {
    let reward_name = type_name::with_defining_ids<Reward>();

    let reward_data = &farm.reward_data[&reward_name];

    let end_time = reward_data.end.min(clock.now());

    let rewards_available = farm.balance<_, Reward>(reward_name).value();

    let accrued_rewards_per_share = if (
        farm.total_stake_amount == 0 || reward_data.last_reward_timestamp >= end_time
    ) {
        reward_data.accrued_rewards_per_share
    } else {
        let (accrued_rewards_per_share, _) = calculate_accrued_rewards(
            reward_data.rewards_per_second,
            reward_data.accrued_rewards_per_share,
            farm.total_stake_amount,
            reward_data.rewards,
            farm.precision,
            end_time - reward_data.last_reward_timestamp,
        );

        accrued_rewards_per_share
    };

    let current_reward_value = account.rewards[&reward_name];

    let pending_rewards =
        calculate_pending_rewards(
        account,
        reward_name,
        farm.precision,
        accrued_rewards_per_share,
    ) + current_reward_value;

    pending_rewards.min(rewards_available)
}

fun update_farm<Stake>(farm: &mut InterestFarm<Stake>, clock: &Clock) {
    let now = clock.now();

    farm.rewards.do!(|reward_name| {
        update_impl(farm, reward_name, now);
    });
}

fun update_with_account<Stake>(
    farm: &mut InterestFarm<Stake>,
    clock: &Clock,
    account: &mut InterestFarmAccount<Stake>,
) {
    let now = clock.now();

    farm.rewards.do!(|reward_name| {
        update_impl(farm, reward_name, now);

        if (account.balance.value() != 0) {
            let reward_data = &mut farm.reward_data[&reward_name];

            let pending_rewards = account.calculate_pending_rewards(
                reward_name,
                farm.precision,
                reward_data.accrued_rewards_per_share,
            );

            if (pending_rewards != 0) {
                let account_rewards = &mut account.rewards[&reward_name];

                *account_rewards = *account_rewards
                        + pending_rewards;
            };
        }
    });
}

fun update_impl<Stake>(farm: &mut InterestFarm<Stake>, reward_name: TypeName, now: u64) {
    let reward_data = &mut farm.reward_data[&reward_name];

    let end_time = reward_data.end.min(now);

    let prev_reward_time_stamp = reward_data.last_reward_timestamp;
    reward_data.last_reward_timestamp = end_time;

    if (
        farm.total_stake_amount != 0 && prev_reward_time_stamp < end_time && reward_data.rewards_per_second != 0 && reward_data.rewards != 0
    ) {
        let (accrued_rewards_per_share, reward) = calculate_accrued_rewards(
            reward_data.rewards_per_second,
            reward_data.accrued_rewards_per_share,
            farm.total_stake_amount,
            reward_data.rewards,
            farm.precision,
            end_time - prev_reward_time_stamp,
        );

        reward_data.accrued_rewards_per_share = accrued_rewards_per_share;
        reward_data.rewards = reward_data.rewards - (reward as u64);

        if (reward_data.rewards == 0) reward_data.rewards_per_second = 0;
    };
}

fun calculate_accrued_rewards(
    rewards_per_second: u64,
    last_accrued_rewards_per_share: u256,
    total_staked_token: u64,
    total_reward_value: u64,
    precision: u256,
    timestamp_delta: u64,
): (u256, u256) {
    let (total_staked_token, total_reward_value, rewards_per_second, timestamp_delta) = (
        total_staked_token as u256,
        total_reward_value as u256,
        rewards_per_second as u256,
        timestamp_delta as u256,
    );

    let reward = total_reward_value.min(
        rewards_per_second * timestamp_delta,
    );

    (
        last_accrued_rewards_per_share + ((reward * precision)
                / total_staked_token),
        reward,
    )
}

fun calculate_pending_rewards<T>(
    account: &InterestFarmAccount<T>,
    reward: TypeName,
    precision: u256,
    accrued_rewards_per_share: u256,
): u64 {
    (
        ((account.balance.value() as u256) * accrued_rewards_per_share
    / precision) - account.reward_debts[&reward],
    ) as u64
}

fun update_reward_debt<T>(account: &mut InterestFarmAccount<T>, farm: &InterestFarm<T>) {
    farm.rewards.do_ref!(|reward_name| {
        let farm_reward_data = farm.reward_data[reward_name];

        let new_debt = calculate_reward_debt_impl(
            account.balance.value(),
            farm.precision,
            farm_reward_data.accrued_rewards_per_share,
        );

        let account_debt = &mut account.reward_debts[reward_name];
        *account_debt = new_debt;
    });
}

fun timestamp_s(clock: &Clock): u64 {
    clock.timestamp_ms() / 1000
}

fun calculate_reward_debt_impl(
    stake_amount: u64,
    precision: u256,
    accrued_rewards_per_share: u256,
): u256 {
    (stake_amount as u256 * accrued_rewards_per_share) / precision
}

fun default_reward_data(): RewardData {
    RewardData {
        rewards: 0,
        rewards_per_second: 0,
        last_reward_timestamp: 0,
        accrued_rewards_per_share: 0,
        end: 0,
    }
}

fun balance<T, Reward>(farm: &InterestFarm<T>, reward: TypeName): &Balance<Reward> {
    df::borrow<RewardBalance, Balance<Reward>>(
        &farm.id,
        RewardBalance(reward),
    )
}

fun balance_mut<T, Reward>(farm: &mut InterestFarm<T>, reward: TypeName): &mut Balance<Reward> {
    df::borrow_mut<RewardBalance, Balance<Reward>>(
        &mut farm.id,
        RewardBalance(reward),
    )
}

// === Aliases ===

use fun timestamp_s as Clock.now;
use fun update_farm as InterestFarm.update;

public use fun destroy_account as InterestFarmAccount.destroy;

// === Test Only Functions ===

#[test_only]
public fun rewards<Stake>(farm: &InterestFarm<Stake>): vector<TypeName> {
    farm.rewards
}

#[test_only]
public fun reward_data<Stake, Reward>(farm: &InterestFarm<Stake>): (u64, u64, u64, u256) {
    let reward_data = farm.reward_data[&type_name::with_defining_ids<Reward>()];

    (
        reward_data.rewards,
        reward_data.rewards_per_second,
        reward_data.last_reward_timestamp,
        reward_data.accrued_rewards_per_share,
    )
}

#[test_only]
public fun reward_end_time<Stake, Reward>(farm: &InterestFarm<Stake>): u64 {
    let reward_data = farm.reward_data[&type_name::with_defining_ids<Reward>()];
    reward_data.end
}

#[test_only]
public fun total_stake_amount<Stake>(farm: &InterestFarm<Stake>): u64 {
    farm.total_stake_amount
}

#[test_only]
public fun precision<Stake>(farm: &InterestFarm<Stake>): u256 {
    farm.precision
}

#[test_only]
public fun paused<Stake>(farm: &InterestFarm<Stake>): bool {
    farm.paused
}

#[test_only]
public fun balance_value<Stake, Reward>(farm: &InterestFarm<Stake>): u64 {
    farm.balance<Stake, Reward>(type_name::with_defining_ids<Reward>()).value()
}

#[test_only]
public fun assert_belongs_to_farm_for_test<Stake>(
    account: &InterestFarmAccount<Stake>,
    farm: &InterestFarm<Stake>,
) {
    account.assert_belongs_to_farm(farm);
}

#[test_only]
public fun account_balance<Stake>(account: &InterestFarmAccount<Stake>): u64 {
    account.balance.value()
}

#[test_only]
public fun account_reward_debts<Stake, Reward>(account: &InterestFarmAccount<Stake>): u256 {
    account.reward_debts[&type_name::with_defining_ids<Reward>()]
}

#[test_only]
public fun account_rewards<Stake, Reward>(account: &InterestFarmAccount<Stake>): u64 {
    account.rewards[&type_name::with_defining_ids<Reward>()]
}

#[test_only]
public fun pending_rewards_for_test<Stake, Reward>(
    account: &InterestFarmAccount<Stake>,
    farm: &InterestFarm<Stake>,
    clock: &Clock,
): u64 {
    account.pending_rewards<_, Reward>(farm, clock)
}

#[test_only]
public fun new_invalid_account_for_test<Stake>(ctx: &mut TxContext): InterestFarmAccount<Stake> {
    InterestFarmAccount {
        id: object::new(ctx),
        farm: @0x0,
        balance: balance::zero(),
        reward_debts: vec_map::empty(),
        rewards: vec_map::empty(),
    }
}
