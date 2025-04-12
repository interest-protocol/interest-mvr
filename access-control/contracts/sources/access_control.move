// Copyright (c) DEFI, LDA
// SPDX-License-Identifier: Apache-2.0

/// This module provides a safe access control mechanism for the contract.
/// The SuperAdmin object has the ability to add and remove admins from the contract.
/// Admins can create a Witness to execute authorized transactions.
/// Author: Jose Cerqueira
module access_control::access_control;

use access_control::events;
use sui::{types, vec_set::{Self, VecSet}};

// === Imports ===

// === Constants ===

/// Each epoch is roughly 1 day
const THREE_EPOCHS: u64 = 3;

// === Structs ===

public struct AdminWitness<phantom T>() has drop;

public struct SuperAdmin<phantom T> has key {
    id: UID,
    new_admin: address,
    start: u64,
}

public struct Admin<phantom T> has key, store {
    id: UID,
}

public struct ACL<phantom T> has key, store {
    id: UID,
    admins: VecSet<address>,
}

// === Public Mutative Functions ===

public fun new<T: drop>(otw: T, super_admin_recipient: address, ctx: &mut TxContext): ACL<T> {
    assert!(types::is_one_time_witness(&otw), access_control::errors::invalid_otw!());
    assert!(super_admin_recipient != @0x0, access_control::errors::invalid_super_admin!());

    let acl = ACL<T> {
        id: object::new(ctx),
        admins: vec_set::empty(),
    };

    let super_admin = SuperAdmin<T> {
        id: object::new(ctx),
        new_admin: @0x0,
        start: std::u64::max_value!(),
    };

    transfer::transfer(super_admin, super_admin_recipient);

    acl
}

public fun new_admin<T: drop>(acl: &mut ACL<T>, _: &SuperAdmin<T>, ctx: &mut TxContext): Admin<T> {
    let admin = Admin {
        id: object::new(ctx),
    };

    acl.admins.insert(admin.id.to_address());

    events::new_admin<T>(admin.id.to_address());

    admin
}

public fun revoke<T: drop>(acl: &mut ACL<T>, _: &SuperAdmin<T>, to_revoke: address) {
    acl.admins.remove(&to_revoke);

    events::revoke_admin<T>(to_revoke);
}

public fun is_admin<T: drop>(acl: &ACL<T>, admin: address): bool {
    acl.admins.contains(&admin)
}

public fun sign_in<T: drop>(acl: &ACL<T>, admin: &Admin<T>): AdminWitness<T> {
    assert!(acl.is_admin(admin.id.to_address()), access_control::errors::invalid_admin!());

    AdminWitness()
}

public fun destroy_admin<T: drop>(acl: &mut ACL<T>, admin: Admin<T>) {
    let Admin { id } = admin;

    let admin_address = id.to_address();

    if (acl.admins.contains(&admin_address)) acl.admins.remove(&admin_address);

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
        access_control::errors::invalid_super_admin!(),
    );

    super_admin.start = ctx.epoch();
    super_admin.new_admin = new_super_admin;

    events::start_super_admin_transfer<T>(new_super_admin, super_admin.start);
}

public fun finish_transfer<T: drop>(mut super_admin: SuperAdmin<T>, ctx: &mut TxContext) {
    assert!(
        ctx.epoch() > super_admin.start + THREE_EPOCHS,
        access_control::errors::invalid_epoch!(),
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
    id.delete();
}

// === Aliases ===

public use fun destroy_super_admin as SuperAdmin.destroy;

// === Test Functions ===

#[test_only]
public fun sign_in_for_testing<T: drop>(): AdminWitness<T> {
    AdminWitness()
}

#[test_only]
public fun admins<T: drop>(acl: &ACL<T>): &VecSet<address> {
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
public fun admin_address<T: drop>(admin: &Admin<T>): address {
    admin.id.to_address()
}
