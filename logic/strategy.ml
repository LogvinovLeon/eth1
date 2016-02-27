open Core.Std;;
open Async.Std;;
open Utils;;
open State;;
open Types.Buy_or_sell;;
open Types.Book;;

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

let average ?trans:(trans=fun x -> x) lst = (let open Types.Trade in
    let (s, n) = List.fold_right lst ~init:(0, 0) ~f:(fun trade (sum, count) ->
        (sum + trans trade.price * trade.size, count + trade.size))
    in s / n);;

let rec estimate_fair ~state ~symbol = match symbol with
    | Types.BOND -> Some (1000, 1000000)
    | symbol -> let open List in let open List.Assoc in
        let trades = sort ~cmp:Pervasives.compare (take (find_exn state.trades symbol) 8000) in
        let trades_len = length trades in
        let trades = take (drop trades (trades_len / 4)) (3 * trades_len / 4) in
        match trades with
            | [] -> None;
            | _ -> Some (average trades,
                        average ~trans:(fun x -> x * x) trades);;

let process_symbol ~symbol ~write state =
    match estimate_fair ~symbol ~state with
        | Some (fair, squared) ->
            begin
                let open Message in
                let stdev = squared - fair * fair |> Float.of_int |> sqrt in
                print_endline (Printf.sprintf "symbol %s: mean %d, stdev = %f" (Action.string_of_symbol symbol) fair stdev);
                market_making ~symbol ~fair ~write ~state;
            end
        | None -> return state;;

(* Returns a pair option - maximum buy price and minimum sell price. *)
let price_range state symbol =
    match get_current_book state symbol with
    | None -> None
    | Some book ->
        let buy_max = List.fold_left book.buy ~init:Int.min_value ~f:(fun x p -> max x p.price)
        and sell_min = List.fold_left book.sell ~init:Int.max_value ~f:(fun x p -> min x p.price) in
        Some (buy_max, sell_min)

let estimate_vale_trade_range state =
    match price_range state Types.VALE with
    | None -> None
    | Some (low, high) ->
        let len = (high - low) / 3 in
        Some (low, low + len, high - len, high)

let rate_ok state symbol =
    let open Time in
    let open Time.Span in
    abs_diff (List.Assoc.find_exn state.last_orders symbol) (now ()) >= min_time_diff symbol

let take_advantage_of_price_diff ~write state =
    match
        rate_ok state Types.VALE,
        estimate_vale_trade_range state,
        estimate_fair ~state:state ~symbol:Types.VALBZ
    with
    | true, Some (mn, low, high, mx), Some (fair_price, _) ->
        if fair_price <= low then
            sell ~symbol:Types.VALE ~price:(mx-1) ~size:1 ~write ~state
        else if fair_price >= high then
            buy ~symbol:Types.VALE ~price:(mn+1) ~size:1 ~write ~state
        else
            return state
    | _ ->
        return state

let lower_vale_position ~write ~assets state =
    if rate_ok state Types.VALE then
        let dir = match compare 0 assets with
            | 1 -> Types.Buy
            | _ -> Types.Sell
        in
        convert
            ~symbol:Types.VALE
            ~dir
            ~size:10
            ~write
            ~state
    else
        return state;;

(* Kamil strategy. *)
let vale_market_making ~write state =
    let assets = List.Assoc.find_exn state.assets Types.VALE in
    if abs assets = 10 then
        lower_vale_position ~write ~assets state
    else
        take_advantage_of_price_diff ~write state

let handle_message ~write ~state ~message =
    process_symbol ~symbol:Types.BOND ~write state >>=
(*  process_symbol ~symbol:Types.VALBZ ~write >>=
    process_symbol ~symbol:Types.VALE ~write >>=
    process_symbol ~symbol:Types.GS ~write >>=
    process_symbol ~symbol:Types.MS ~write >>=
    process_symbol ~symbol:Types.WFC ~write >>= *)
    vale_market_making ~write;;
(* process_symbol ~symbol:Types.XLF ~write;; *)

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

