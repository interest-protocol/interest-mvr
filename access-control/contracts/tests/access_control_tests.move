#[test_only, allow(unused_mut_ref)]
module interest_access_control::access_control_tests;

use interest_access_control::access_control::{Self, ACL, SuperAdmin};
use sui::{test_scenario::{Self as ts, Scenario}, test_utils::{destroy, assert_eq}};

const ADMIN: address = @0xa11ce;
const NEW_ADMIN: address = @0xdead;

public struct TestWitness() has drop;

const DELAY: u64 = 2;

const ROLE_1: u8 = 0;
const ROLE_2: u8 = 34;
const ROLE_3: u8 = 127;

public struct Dapp {
    scenario: Option<Scenario>,
    acl: Option<ACL<TestWitness>>,
    super_admin: Option<SuperAdmin<TestWitness>>,
}

#[test]
fun test_new() {
    let mut dapp = deploy();

    dapp.tx!(|acl, super_admin_option, _scenario| {
        let super_admin = super_admin_option.borrow();

        assert_eq(acl.admins().size(), 0);
        assert_eq(super_admin.new_admin(), @0x0);
        assert_eq(super_admin.start(), std::u64::max_value!());
        assert_eq(super_admin.delay(), DELAY);
    });

    dapp.end();
}

#[test]
fun test_new_admin() {
    let mut dapp = deploy();

    dapp.tx!(|acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow();

        assert_eq(acl.admins().size(), 0);

        let admin = acl.new_admin(super_admin, scenario.ctx());

        assert_eq(acl.admins().size(), 1);
        assert_eq(acl.is_admin(admin.address()), true);

        acl.destroy_admin(admin);
    });

    dapp.end();
}

#[test]
fun test_revoke() {
    let mut dapp = deploy();

    dapp.tx!(|acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow();

        assert_eq(acl.admins().size(), 0);

        let admin = acl.new_admin(super_admin, scenario.ctx());

        assert_eq(acl.admins().size(), 1);
        assert_eq(acl.is_admin(admin.address()), true);

        acl.add_role(super_admin, admin.address(), ROLE_1);

        assert_eq(acl.has_role(admin.address(), ROLE_1), true);

        acl.revoke(super_admin, admin.address());

        assert_eq(acl.has_role(admin.address(), ROLE_1), false);
        assert_eq(acl.permissions(admin.address()).is_some(), false);

        assert_eq(acl.admins().size(), 0);
        assert_eq(acl.is_admin(admin.address()), false);

        acl.destroy_admin(admin);
    });

    dapp.end();
}

#[test]
fun test_super_admin_transfer() {
    let mut dapp = deploy();

    dapp.tx!(|_acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow_mut();

        assert_eq(super_admin.new_admin(), @0x0);
        assert_eq(super_admin.start(), std::u64::max_value!());

        scenario.next_epoch(ADMIN);
        scenario.next_epoch(ADMIN);

        super_admin.start_transfer(NEW_ADMIN, scenario.ctx());

        assert_eq(super_admin.new_admin(), NEW_ADMIN);
        assert_eq(super_admin.start(), 2);

        (DELAY + 1).do!(|_| {
            scenario.next_epoch(ADMIN);
        });

        let super_admin = super_admin_option.extract();

        super_admin.finish_transfer(scenario.ctx());

        scenario.next_epoch(NEW_ADMIN);

        let super_admin = scenario.take_from_sender<SuperAdmin<TestWitness>>();

        assert_eq(super_admin.new_admin(), @0x0);
        assert_eq(super_admin.start(), std::u64::max_value!());

        destroy(super_admin);
    });

    dapp.end();
}

#[test]
fun test_sign_in() {
    let mut dapp = deploy();

    dapp.tx!(|acl, super_admin_option, scenario| {
        assert_eq(acl.admins().size(), 0);

        let super_admin = super_admin_option.borrow();

        let admin = acl.new_admin(super_admin, scenario.ctx());

        assert_eq(acl.admins().size(), 1);
        assert_eq(acl.is_admin(admin.address()), true);

        let _witness = acl.sign_in(&admin);

        acl.destroy_admin(admin);
    });

    dapp.end();
}

#[test]
fun test_sign_in_with_roles() {
    let mut dapp = deploy();

    dapp.tx!(|acl, super_admin_option, scenario| {
        assert_eq(acl.admins().size(), 0);

        let super_admin = super_admin_option.borrow();

        let admin = acl.new_admin(super_admin, scenario.ctx());

        let admin_address = admin.address();

        assert_eq(acl.admins().size(), 1);
        assert_eq(acl.is_admin(admin_address), true);

        assert_eq(*acl.permissions(admin.address()).borrow(), 0);

        acl.add_role(super_admin, admin_address, ROLE_1);
        acl.add_role(super_admin, admin_address, ROLE_2);
        acl.add_role(super_admin, admin_address, ROLE_3);

        assert_eq(acl.permissions(admin_address).is_some(), true);
        assert_eq(
            *acl.permissions(admin_address).borrow(),
            (1 << ROLE_1) | (1 << ROLE_2) | (1 << ROLE_3),
        );

        (128u8).do!(|role| {
            if (role == ROLE_1 || role == ROLE_2 || role == ROLE_3) {
                assert_eq(acl.has_role(admin_address, role), true);
            } else {
                assert_eq(acl.has_role(admin_address, role), false);
            }
        });

        let witness = acl.sign_in(&admin);

        witness.assert_has_role(ROLE_1);
        witness.assert_has_role(ROLE_2);
        witness.assert_has_role(ROLE_3);

        assert_eq(witness.witness_permissions(), (1 << ROLE_1) | (1 << ROLE_2) | (1 << ROLE_3));

        acl.destroy_admin(admin);
    });

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidPermissions,
        location = access_control,
    ),
]
fun test_sign_in_invalid_permission() {
    let mut dapp = deploy();

    dapp.tx!(
        |acl, super_admin_option, scenario| {
            let super_admin = super_admin_option.borrow();
            let admin = acl.new_admin(super_admin, scenario.ctx());
            let admin_address = admin.address();

            acl.add_role(super_admin, admin_address, ROLE_1);
            acl.add_role(super_admin, admin_address, ROLE_2);

            acl.sign_in(&admin).assert_has_role(ROLE_2);

            acl.remove_role(super_admin, admin_address, ROLE_2);

            acl.sign_in(&admin).assert_has_role(ROLE_2);

            acl.destroy_admin(admin);
        },
    );

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidRole,
        location = access_control,
    ),
]
fun test_add_invalid_role() {
    let mut dapp = deploy();

    dapp.tx!(
        |acl, super_admin_option, scenario| {
            let super_admin = super_admin_option.borrow();
            let admin = acl.new_admin(super_admin, scenario.ctx());
            let admin_address = admin.address();

            acl.add_role(super_admin, admin_address, 128);

            acl.destroy_admin(admin);
        },
    );

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidAdmin,
        location = access_control,
    ),
]
fun test_add_role_invalid_admin() {
    let mut dapp = deploy();

    dapp.tx!(
        |acl, super_admin_option, _scenario| {
            let super_admin = super_admin_option.borrow();

            acl.add_role(super_admin, @0x3, 0);
        },
    );

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidAdmin,
        location = access_control,
    ),
]
fun test_remove_role_invalid_admin() {
    let mut dapp = deploy();

    dapp.tx!(
        |acl, super_admin_option, _scenario| {
            let super_admin = super_admin_option.borrow();

            acl.remove_role(super_admin, @0x3, 0);
        },
    );

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidRole,
        location = access_control,
    ),
]
fun test_remove_invalid_role() {
    let mut dapp = deploy();

    dapp.tx!(
        |acl, super_admin_option, scenario| {
            let super_admin = super_admin_option.borrow();
            let admin = acl.new_admin(super_admin, scenario.ctx());
            let admin_address = admin.address();

            acl.remove_role(super_admin, admin_address, 128);

            acl.destroy_admin(admin);
        },
    );

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidOTW,
        location = access_control,
    ),
]
fun test_new_otw() {
    let acl = access_control::new(&TestWitness(), DELAY, ADMIN, &mut tx_context::dummy());

    destroy(acl);
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidSuperAdmin,
        location = access_control,
    ),
]
fun test_super_admin_transfer_error_same_sender() {
    let mut dapp = deploy();

    dapp.tx!(|_acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow_mut();

        super_admin.start_transfer(ADMIN, scenario.ctx());
    });

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidSuperAdmin,
        location = access_control,
    ),
]
fun test_super_admin_transfer_error_zero_address() {
    let mut dapp = deploy();

    dapp.tx!(|_acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow_mut();

        super_admin.start_transfer(@0x0, scenario.ctx());
    });

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidEpoch,
        location = access_control,
    ),
]
fun test_super_admin_finish_transfer_invalid_epoch() {
    let mut dapp = deploy();

    dapp.tx!(|_acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow_mut();

        super_admin.start_transfer(NEW_ADMIN, scenario.ctx());

        scenario.next_epoch(ADMIN);
        scenario.next_epoch(ADMIN);

        let super_admin = super_admin_option.extract();

        super_admin.finish_transfer(scenario.ctx());
    });

    dapp.end();
}

#[
    test,
    expected_failure(
        abort_code = interest_access_control::errors::EInvalidAdmin,
        location = access_control,
    ),
]
fun test_sign_in_error_invalid_admin() {
    let mut dapp = deploy();

    dapp.tx!(|acl, super_admin_option, scenario| {
        let super_admin = super_admin_option.borrow();

        assert_eq(acl.admins().size(), 0);

        let admin = acl.new_admin(super_admin, scenario.ctx());

        acl.revoke(super_admin, admin.address());

        let _witness = acl.sign_in(&admin);

        acl.destroy_admin(admin);
    });

    dapp.end();
}

macro fun tx(
    $dapp: &mut Dapp,
    $f: |&mut ACL<TestWitness>, &mut Option<SuperAdmin<TestWitness>>, &mut Scenario|,
) {
    let dapp = $dapp;

    let mut acl = dapp.acl.extract();
    let mut scenario = dapp.scenario.extract();

    $f(&mut acl, &mut dapp.super_admin, &mut scenario);

    dapp.acl.fill(acl);
    dapp.scenario.fill(scenario);
}

fun deploy(): Dapp {
    let mut scenario = ts::begin(ADMIN);
    let acl = access_control::new_for_testing<TestWitness>(DELAY, ADMIN, scenario.ctx());

    scenario.next_tx(ADMIN);

    let super_admin = scenario.take_from_sender<SuperAdmin<TestWitness>>();

    Dapp {
        scenario: option::some(scenario),
        acl: option::some(acl),
        super_admin: option::some(super_admin),
    }
}

fun end(dapp: Dapp) {
    destroy(dapp);
}

// === Aliases ===

use fun access_control::super_admin_start as SuperAdmin.start;
use fun access_control::super_admin_new_admin as SuperAdmin.new_admin;
