open Core.Std;;
open Async.Std;;
open Utils;;

let handle_message ~write ~state ~message =
    let do_buy state = 
        let h_buy = State.get_highest_buy state Types.BOND
        and order = State.get_buy_order state Types.BOND
        in
        let our_price = Option.value_map order ~default:Int.min_value ~f:(fun order -> order.price)
        and market_price = Option.value_map h_buy ~default:(Int.min_value + 1) ~f:(fun v -> v)
        in
        if market_price > our_price && market_price + 1 < 1000 then
            buy
                ~symbol:Types.BOND
                ~price:(max (market_price + 1) 1)
                ~size:1
                ~write
                ~state >>= fun state ->
            Option.value_map order
                ~default:(return ())
                ~f:(fun {order_id; _} -> cancel ~order_id ~write) >>= fun () ->
            return state
        else return state
    and do_sell state = 
        let l_sell = State.get_lowest_sell state Types.BOND
        and order = State.get_sell_order state Types.BOND
        in
        let our_price = Option.value_map order ~default:(Int.max_value - 1) ~f:(fun order -> order.price)
        and market_price = Option.value_map l_sell ~default:Int.max_value ~f:(fun v -> v)
        in
        if market_price < our_price && market_price - 1 > 1000 then
            sell
                ~symbol:Types.BOND
                ~price:(max (market_price - 1) 1)
                ~size:1
                ~write
                ~state >>= fun state ->
            Option.value_map order
                ~default:(return ())
                ~f:(fun {order_id; _} -> cancel ~order_id ~write) >>= fun () ->
            return state
        else return state
    in do_buy state >>= do_sell;;

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

