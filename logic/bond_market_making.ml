open Core.Std;;
open Async.Std;;
open Utils;;

let market_making ~symbol ~fair ~write ~state =
    let do_buy state = 
        let h_buy = State.get_highest_buy state symbol
        and order = State.get_buy_order state symbol
        in
        let our_price = Option.value_map order ~default:Int.min_value ~f:(fun order -> order.price)
        and market_price = Option.value_map h_buy ~default:(Int.min_value + 1) ~f:(fun v -> v)
        in
        if market_price > our_price && market_price + 1 < fair then
            buy
                ~symbol
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
        let l_sell = State.get_lowest_sell state symbol
        and order = State.get_sell_order state symbol
        in
        let our_price = Option.value_map order ~default:(Int.max_value - 1) ~f:(fun order -> order.price)
        and market_price = Option.value_map l_sell ~default:Int.max_value ~f:(fun v -> v)
        in
        if market_price < our_price && market_price - 1 > fair then
            sell
                ~symbol
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

let estimate_fair ~state ~symbol = match symbol with
    | Types.BOND -> Some 1000
    | symbol ->
        match (State.get_highest_buy state symbol, State.get_lowest_sell state symbol) with
            | (Some hi, Some lo) -> Some ((hi + lo) / 2)
            | _ -> None;;

let process_symbol ~symbol ~write state =
    match estimate_fair ~symbol ~state with
        | Some fair -> market_making ~symbol ~fair ~write ~state
        | None -> return state;;

let handle_message ~write ~state ~message =
    process_symbol ~symbol:Types.BOND ~write state >>=
(*    process_symbol ~symbol:Types.VALBZ ~write >>= *)
(*    process_symbol ~symbol:Types.VALE ~write >>= *)
    process_symbol ~symbol:Types.GS ~write >>=
    process_symbol ~symbol:Types.MS ~write >>=
    process_symbol ~symbol:Types.WFC ~write;;
        (*    process_symbol ~symbol:Types.XLF ~write *)

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

