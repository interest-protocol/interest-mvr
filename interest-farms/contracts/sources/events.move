module interest_farms::interest_farm_events;

use std::type_name::TypeName;
use sui::{event::emit, vec_map::VecMap};

public struct InterestFarmEvent<T: copy + drop>(T) has copy, drop;

public struct NewAccount has copy, drop {
    farm: address,
    account: address,
}

public struct DestroyAccount(address) has copy, drop;

public struct Stake has copy, drop {
    farm: address,
    account: address,
    amount: u64,
    total_stake_amount: u64,
    stake: TypeName,
    account_balance: u64,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
}

public struct Unstake has copy, drop {
    farm: address,
    account: address,
    amount: u64,
    total_stake_amount: u64,
    stake: TypeName,
    account_balance: u64,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
}

public struct Harvest has copy, drop {
    farm: address,
    account: address,
    amount: u64,
    reward: TypeName,
    account_balance: u64,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
}

public struct UpdateReward has copy, drop {
    farm: address,
    reward: TypeName,
    rewards: u64,
    rewards_per_second: u64,
    last_reward_timestamp: u64,
    accrued_rewards_per_share: u256,
}

public struct AddReward has copy, drop {
    farm: address,
    reward: TypeName,
    amount: u64,
}

public struct NewFarm has copy, drop {
    farm: address,
    rewards: vector<TypeName>,
    admin_type: TypeName,
}

public struct Pause(address) has copy, drop;

public struct Unpause(address) has copy, drop;

public struct SetRewardsPerSecond has copy, drop {
    farm: address,
    reward: TypeName,
    old_rewards_per_second: u64,
    new_rewards_per_second: u64,
}

public struct SetEndTime has copy, drop {
    farm: address,
    reward: TypeName,
    end: u64,
}

// === Package Functions ===

public(package) fun emit_new_account(farm: address, account: address) {
    emit(InterestFarmEvent(NewAccount { farm, account }));
}

public(package) fun emit_destroy_account(account: address) {
    emit(InterestFarmEvent(DestroyAccount(account)));
}

public(package) fun emit_stake(
    farm: address,
    account: address,
    amount: u64,
    total_stake_amount: u64,
    stake: TypeName,
    account_balance: u64,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
) {
    emit(
        InterestFarmEvent(Stake {
            farm,
            account,
            amount,
            total_stake_amount,
            stake,
            account_balance,
            reward_debts,
            rewards,
        }),
    );
}

public(package) fun emit_unstake(
    farm: address,
    account: address,
    amount: u64,
    total_stake_amount: u64,
    stake: TypeName,
    account_balance: u64,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
) {
    emit(
        InterestFarmEvent(Unstake {
            farm,
            account,
            amount,
            total_stake_amount,
            stake,
            account_balance,
            reward_debts,
            rewards,
        }),
    );
}

public(package) fun emit_harvest(
    farm: address,
    account: address,
    amount: u64,
    reward: TypeName,
    account_balance: u64,
    reward_debts: VecMap<TypeName, u256>,
    rewards: VecMap<TypeName, u64>,
) {
    emit(
        InterestFarmEvent(Harvest {
            farm,
            account,
            amount,
            reward,
            account_balance,
            reward_debts,
            rewards,
        }),
    );
}

public(package) fun emit_add_reward(farm: address, reward: TypeName, amount: u64) {
    emit(InterestFarmEvent(AddReward { farm, reward, amount }));
}

public(package) fun emit_new_farm(farm: address, rewards: vector<TypeName>, admin_type: TypeName) {
    emit(InterestFarmEvent(NewFarm { farm, rewards, admin_type }));
}

public(package) fun emit_pause(farm: address) {
    emit(InterestFarmEvent(Pause(farm)));
}

public(package) fun emit_unpause(farm: address) {
    emit(InterestFarmEvent(Unpause(farm)));
}

public(package) fun emit_set_rewards_per_second(
    farm: address,
    reward: TypeName,
    old_rewards_per_second: u64,
    new_rewards_per_second: u64,
) {
    emit(
        InterestFarmEvent(SetRewardsPerSecond {
            farm,
            reward,
            old_rewards_per_second,
            new_rewards_per_second,
        }),
    );
}

public(package) fun emit_set_end_time(farm: address, reward: TypeName, end: u64) {
    emit(InterestFarmEvent(SetEndTime { farm, reward, end }));
}

public(package) fun emit_update_reward(
    farm: address,
    reward: TypeName,
    rewards: u64,
    rewards_per_second: u64,
    last_reward_timestamp: u64,
    accrued_rewards_per_share: u256,
) {
    emit(
        InterestFarmEvent(UpdateReward {
            farm,
            reward,
            rewards,
            rewards_per_second,
            last_reward_timestamp,
            accrued_rewards_per_share,
        }),
    );
}
