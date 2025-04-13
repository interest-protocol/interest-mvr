// Copyright (c) DEFI, LDA
// SPDX-License-Identifier: Apache-2.0

/// This module provides a safe access control mechanism for contracts.
/// The SuperAdmin object has the ability to add and remove admins from the contract and manage roles.
/// Admins can create a Witness to execute authorized transactions.
/// Author: Jose Cerqueira
module interest_access_control::access_control;

use interest_access_control::events;
use sui::{types, vec_map::{Self, VecMap}};

// === Structs ===

public struct AdminWitness<phantom T>(u128) has drop;

public struct SuperAdmin<phantom T> has key {
    id: UID,
    new_admin: address,
    start: u64,
    delay: u64,
}

public struct Admin<phantom T> has key, store {
    id: UID,
}

public struct ACL<phantom T> has key, store {
    id: UID,
    admins: VecMap<address, u128>,
}

// === Public Mutative Functions ===

public fun new<T: drop>(
    otw: &T,
    delay: u64,
    super_admin_recipient: address,
    ctx: &mut TxContext,
): ACL<T> {
    assert!(types::is_one_time_witness(otw), interest_access_control::errors::invalid_otw!());

    new_impl(delay, super_admin_recipient, ctx)
}

public fun default<T: drop>(otw: &T, ctx: &mut TxContext): ACL<T> {
    new(otw, 3, ctx.sender(), ctx)
}

public fun new_admin<T: drop>(acl: &mut ACL<T>, _: &SuperAdmin<T>, ctx: &mut TxContext): Admin<T> {
    let admin = Admin {
        id: object::new(ctx),
    };

    acl.admins.insert(admin.id.to_address(), 0);

    events::new_admin<T>(admin.id.to_address());

    admin
}

public fun add_role<T: drop>(acl: &mut ACL<T>, _: &SuperAdmin<T>, admin: address, role: u8) {
    assert!(128 > role, interest_access_control::errors::invalid_role!());
    assert!(acl.is_admin(admin), interest_access_control::errors::invalid_admin!());

    events::role_added<T>(admin, role);

    let permissions = &mut acl.admins[&admin];
    *permissions = *permissions | (1 << role);
}

public fun remove_role<T: drop>(acl: &mut ACL<T>, _: &SuperAdmin<T>, admin: address, role: u8) {
    assert!(128 > role, interest_access_control::errors::invalid_role!());
    assert!(acl.is_admin(admin), interest_access_control::errors::invalid_admin!());

    events::role_removed<T>(admin, role);

    let permissions = &mut acl.admins[&admin];
    *permissions = *permissions - (1 << role);
}

public fun revoke<T: drop>(acl: &mut ACL<T>, _: &SuperAdmin<T>, to_revoke: address) {
    acl.admins.remove(&to_revoke);

    events::revoke_admin<T>(to_revoke);
}

public fun sign_in<T: drop>(acl: &ACL<T>, admin: &Admin<T>): AdminWitness<T> {
    let admin_address = admin.id.to_address();
    assert!(acl.is_admin(admin_address), interest_access_control::errors::invalid_admin!());

    AdminWitness(acl.admins[&admin_address])
}

public fun destroy_admin<T: drop>(acl: &mut ACL<T>, admin: Admin<T>) {
    let Admin { id } = admin;

    let admin_address = id.to_address();

    if (acl.admins.contains(&admin_address)) {
        acl.admins.remove(&admin_address);
    };

    events::admin_destroyed<T>(admin_address);

    id.delete();
}

// === Transfer Super Admin ===

/// It will abort if the new super admin is the same as the current one or the 0x0 address
public fun start_transfer<T: drop>(
    super_admin: &mut SuperAdmin<T>,
    new_super_admin: address,
    ctx: &mut TxContext,
) {
    assert!(
        new_super_admin != @0x0 && new_super_admin != ctx.sender(),
        interest_access_control::errors::invalid_super_admin!(),
    );

    super_admin.start = ctx.epoch();
    super_admin.new_admin = new_super_admin;

    events::start_super_admin_transfer<T>(new_super_admin, super_admin.start);
}

public fun finish_transfer<T: drop>(mut super_admin: SuperAdmin<T>, ctx: &mut TxContext) {
    assert!(
        ctx.epoch() > super_admin.start + super_admin.delay,
        interest_access_control::errors::invalid_epoch!(),
    );

    let new_admin = super_admin.new_admin;
    super_admin.new_admin = @0x0;
    super_admin.start = std::u64::max_value!();

    transfer::transfer(super_admin, new_admin);

    events::finish_super_admin_transfer<T>(new_admin);
}

/// This is irreversible, the contract does not offer a way to create a new super admin
public fun destroy_super_admin<T: drop>(super_admin: SuperAdmin<T>) {
    let SuperAdmin { id, .. } = super_admin;

    events::super_admin_destroyed<T>(id.to_address());

    id.delete();
}

// === Public View Functions ===

public fun admin_address<T: drop>(admin: &Admin<T>): address {
    admin.id.to_address()
}

public fun is_admin<T: drop>(acl: &ACL<T>, admin: address): bool {
    acl.admins.contains(&admin)
}

public fun has_role<T: drop>(acl: &ACL<T>, admin: address, role: u8): bool {
    if (!acl.is_admin(admin) || role > 128) return false;

    check_role(acl.admins[&admin], role)
}

public fun permissions<T: drop>(acl: &ACL<T>, admin: address): Option<u128> {
    if (!acl.is_admin(admin)) return option::none();

    option::some(acl.admins[&admin])
}

// === Assertions ===

public fun assert_has_role<T: drop>(witness: &AdminWitness<T>, role: u8) {
    assert!(check_role(witness.0, role), interest_access_control::errors::invalid_permissions!());
}

// === Private Functions ===

fun check_role(permissions: u128, role: u8): bool {
    if (role > 128) return false;
    (permissions & (1 << role)) != 0
}

fun new_impl<T: drop>(delay: u64, super_admin_recipient: address, ctx: &mut TxContext): ACL<T> {
    assert!(super_admin_recipient != @0x0, interest_access_control::errors::invalid_super_admin!());

    let acl = ACL<T> {
        id: object::new(ctx),
        admins: vec_map::empty(),
    };

    let super_admin = SuperAdmin<T> {
        id: object::new(ctx),
        new_admin: @0x0,
        start: std::u64::max_value!(),
        delay,
    };

    events::new_super_admin<T>(
        acl.id.to_address(),
        super_admin.id.to_address(),
        super_admin_recipient,
        delay,
    );

    transfer::transfer(super_admin, super_admin_recipient);

    acl
}

// === Aliases ===

public use fun admin_address as Admin.address;
public use fun destroy_super_admin as SuperAdmin.destroy;

// === Test Functions ===

#[test_only]
public fun new_for_testing<T: drop>(delay: u64, super_admin_recipient: address, ctx: &mut TxContext): ACL<T> {
    new_impl(delay, super_admin_recipient, ctx)
}

#[test_only]
public fun sign_in_for_testing<T: drop>(permissions: u128): AdminWitness<T> {
    AdminWitness(permissions)
}

#[test_only]
public fun admins<T: drop>(acl: &ACL<T>): &VecMap<address, u128> {
    &acl.admins
}

#[test_only]
public fun super_admin_new_admin<T: drop>(super_admin: &SuperAdmin<T>): address {
    super_admin.new_admin
}

#[test_only]
public fun super_admin_start<T: drop>(super_admin: &SuperAdmin<T>): u64 {
    super_admin.start
}

#[test_only]
public fun delay<T: drop>(super_admin: &SuperAdmin<T>): u64 {
    super_admin.delay
}

#[test_only]
public fun witness_permissions<T: drop>(witness: &AdminWitness<T>): u128 {
    witness.0
}
