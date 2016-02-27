open Core.Std;;
open Async.Std;;

let buy_or_sell dir market_offer our_offer =
    let default_price = if dir = 1 then Int.min_value else Int.max_value in
    let our_price =
        match our_offer with
        | None -> default_price
        | Some order -> order.price
    in
    let market_price =
        match market_offer with
        | None -> default_price + dir
        | Some v -> v
    in
    if (compare market_price our_price) = dir && (compare (market_price + dir) 1000) = -dir then
        (let state, id = State.get_id state in
        write ((if dir = 1 then Action.Buy else Action.Sell)
            {Types.Buy_or_sell.
            order_id = id;
            symbol = Types.BOND;
            price = market_price + dir;
            size = 5
            })
        >>= fun () ->
            (match our_offer with
            | Some {order_id; _} -> write (Action.Cancel {order_id})
            | None -> return ())
        >>| fun () -> state)
    else return state;;

let handle_message ~write ~state ~message =
    let market_high_buy = State.get_highest_buy state Types.BOND in
    let market_low_sell = State.get_lowest_sell state Types.BOND in
    let our_buy_order = State.get_buy_order state Types.BOND in
    let our_sell_order = State.get_sell_order state Types.BOND in
    buy_or_sell 1 market_high_buy our_buy_order
    >>= fun state ->
    buy_or_sell -1 market_low_sell our_sell_ourder

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

