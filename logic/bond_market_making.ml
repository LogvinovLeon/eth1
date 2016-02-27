open Core.Std;;
open Async.Std;;
open Utils;;
open State;;
open Types.Buy_or_sell;;

let position_limit = function
    | Types.VALBZ | Types.VALE -> 10
    | _ -> 100;;

let min_time_diff = function
    | Types.BOND -> Time.Span.of_sec 0.
    | _ -> Time.Span.of_sec 0.5;;

let market_making ~symbol ~fair ~write ~state =
    let buy_or_sell dir market_offer our_order state =
        let default_price = if dir = 1 then Int.min_value else Int.max_value in
        let our_price = Option.value_map our_order ~default:default_price ~f:(fun order -> order.price)
        and market_price = Option.value_map market_offer ~default:(default_price + dir) ~f:(fun v -> v)
        in
        if compare market_price our_price = dir 
           && compare (market_price + dir) fair = -dir
           && abs (List.Assoc.find_exn state.assets symbol + 2 * dir) <= position_limit symbol
           && (let open Time in let open Time.Span in
                 abs_diff (List.Assoc.find_exn state.last_orders symbol) (now ()) >= min_time_diff symbol)
           && Option.is_some market_offer
        then
            Warnings.info_return ("asset: " ^ string_of_int (List.Assoc.find_exn state.assets symbol))
            (if dir = 1 then buy else sell)
                ~symbol
                ~price:(market_price + dir) (* Gonna be extreme if there are no market offers *)
                ~size:1
                ~write
                ~state >>= fun state ->
            Option.value_map our_order
                ~default:(return ())
                ~f:(fun {order_id; _} -> cancel ~order_id ~write) >>= fun () ->
            return state
        else return state
    in
    let market_high_buy = State.get_highest_buy state symbol
    and our_buy_order = State.get_buy_order state symbol
    and market_low_sell = State.get_lowest_sell state symbol
    and our_sell_order = State.get_sell_order state symbol
    in
    (buy_or_sell 1 market_high_buy our_buy_order state)
    >>= (buy_or_sell (-1) market_low_sell our_sell_order);;

let rec estimate_fair ~state ~symbol = match symbol with
    | Types.BOND -> Some 1000
    | Types.VALE -> estimate_fair ~symbol:Types.VALBZ ~state
    | symbol ->
        match (State.get_highest_buy state symbol, State.get_lowest_sell state symbol) with
            | (Some hi, Some lo) -> Some ((hi + lo) / 2)
            | _ -> None;;

let process_symbol ~symbol ~write state =
    match estimate_fair ~symbol ~state with
        | Some fair -> market_making ~symbol ~fair ~write ~state
        | None -> return state;;

let handle_message ~write ~state ~message =
    process_symbol ~symbol:Types.BOND ~write state (*>>=
    process_symbol ~symbol:Types.VALBZ ~write >>=
    process_symbol ~symbol:Types.VALE ~write >>=
    process_symbol ~symbol:Types.GS ~write >>=
    process_symbol ~symbol:Types.MS ~write >>=
    process_symbol ~symbol:Types.WFC ~write;;
process_symbol ~symbol:Types.XLF ~write;; *)

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

