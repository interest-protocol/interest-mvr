#[test_only]
module interest_farms::ipx;

use sui::coin;

public struct IPX() has drop;

#[lint_allow(share_owned)]
fun init(witness: IPX, ctx: &mut TxContext) {
    let (treasury_cap, metadata) = coin::create_currency<IPX>(
        witness,
        9,
        b"IPX",
        b"IPX",
        b"IPX",
        option::none(),
        ctx,
    );

    transfer::public_transfer(treasury_cap, tx_context::sender(ctx));
    transfer::public_share_object(metadata);
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext) {
    init(IPX(), ctx);
}
