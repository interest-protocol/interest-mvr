// Copyright (c) DEFI, LDA
// SPDX-License-Identifier: Apache-2.0

/// This module provides events for the access control contract.
/// Author: Jose Cerqueira
module access_control::events;

use sui::event::emit;

// === Structs ===

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

// === Package Functions ===

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
