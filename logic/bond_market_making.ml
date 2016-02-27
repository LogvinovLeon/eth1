open Core.Std;;
open Async.Std;;

let handle_message ~write ~state ~message =
    let h_buy = State.get_highest_buy state Types.BOND in
    let l_sell = State.get_lowest_sell state Types.BOND in
    let buy_order = State.get_buy_order state Types.BOND in
    let sell_order = State.get_sell_order state Types.BOND in
    let our_buy_price =
        match buy_order with
        | None -> Int.min_value
        | Some order -> order.price
    in
    let market_buy_price =
        match h_buy with
        | None -> Int.min_value + 1
        | Some v -> v
    in
    if market_buy_price > our_buy_price && market_buy_price + 1 < 1000 then
        (let state, id = State.get_id state in
        write (Action.Buy
            {Types.Buy_or_sell.
            order_id = id;
            symbol = Types.BOND;
            price = max (market_buy_price + 1) 1;
            size = 1
            })
        >>= fun () ->
            (match buy_order with
            | Some {order_id; _} -> write (Action.Cancel {order_id})
            | None -> return ())
        >>| fun () -> state)
    else return state;;

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

