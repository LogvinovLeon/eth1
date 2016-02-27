open Core.Std;;
open Async.Std;;
open Utils;;
open Types.Buy_or_sell;;


let handle_message ~write ~state ~message =
    let buy_or_sell dir market_offer our_offer =
        let default_price = if dir = 1 then Int.min_value else Int.max_value in
        let our_price = Option.value_map our_offer ~default:default_price ~f:(fun order -> order.price)
        and market_price = Option.value_map market_offer ~default:(default_price + dir) ~f:(fun v -> v)
        in
        if compare market_price our_price = dir && compare (market_price + dir) 1000 = -dir then
            (if dir = 1 then buy else sell)
                ~symbol:Types.BOND
                ~price:(market_price + dir) (* Gonna be extreme if there are no market offers *)
                ~size:1
                ~write
                ~state >>= fun state ->
            Option.value_map our_offer
                ~default:(return ())
                ~f:(fun {order_id; _} -> cancel ~order_id ~write) >>= fun () ->
            return state
        else return state
    in
    let market_high_buy = State.get_highest_buy state Types.BOND
    and our_buy_order = State.get_buy_order state Types.BOND
    and market_low_sell = State.get_lowest_sell state Types.BOND
    and our_sell_order = State.get_sell_order state Types.BOND
    in
    buy_or_sell 1 market_high_buy our_buy_order
    >>= buy_or_sell -1 market_low_sell our_sell_order;;

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

