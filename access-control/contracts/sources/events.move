// Copyright (c) DEFI, LDA
// SPDX-License-Identifier: Apache-2.0

/// This module provides events for the access control contract.
/// Author: Jose Cerqueira
module interest_access_control::events;

use sui::event::emit;

// === Structs ===

public struct New<phantom T> has copy, drop {
    new_super_admin: address,
    super_admin_recipient: address,
    acl: address,
    delay: u64,
}

public struct StartSuperAdminTransfer<phantom T> has copy, drop {
    new_admin: address,
    start: u64,
}

public struct FinishSuperAdminTransfer<phantom T> has copy, drop {
    new_admin: address,
}

public struct NewAdmin<phantom T> has copy, drop {
    admin: address,
}

public struct RevokeAdmin<phantom T> has copy, drop {
    admin: address,
}

public struct AdminDestroyed<phantom T>(address) has copy, drop;

public struct SuperAdminDestroyed<phantom T>(address) has copy, drop;

public struct RoleAdded<phantom T>(address, u8) has copy, drop;

public struct RoleRemoved<phantom T>(address, u8) has copy, drop;

// === Package Functions ===

public(package) fun new_super_admin<T>(
    acl: address,
    new_super_admin: address,
    super_admin_recipient: address,
    delay: u64,
) {
    emit(New<T> {
        new_super_admin,
        super_admin_recipient,
        acl,
        delay,
    });
}

public(package) fun start_super_admin_transfer<T>(new_admin: address, start: u64) {
    emit(StartSuperAdminTransfer<T> {
        new_admin,
        start,
    });
}

public(package) fun finish_super_admin_transfer<T>(new_admin: address) {
    emit(FinishSuperAdminTransfer<T> {
        new_admin,
    });
}

public(package) fun new_admin<T>(admin: address) {
    emit(NewAdmin<T> {
        admin,
    });
}

public(package) fun revoke_admin<T>(admin: address) {
    emit(RevokeAdmin<T> {
        admin,
    });
}

public(package) fun admin_destroyed<T>(admin: address) {
    emit(AdminDestroyed<T>(admin));
}

public(package) fun super_admin_destroyed<T>(super_admin: address) {
    emit(SuperAdminDestroyed<T>(super_admin));
}

public(package) fun role_added<T>(admin: address, role: u8) {
    emit(RoleAdded<T>(admin, role));
}

public(package) fun role_removed<T>(admin: address, role: u8) {
    emit(RoleRemoved<T>(admin, role));
}
