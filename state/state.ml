open Core.Std;;
open Sexplib.Std;;
open Types;;
open Warnings;;

type t = {(* TODO *)
    orders : (order_id_t * (Buy_or_sell.t * bool (* Is accepted *))) list;
    assets : (symbol_t * size_t) list;
} with sexp;;

let initial = {
    orders = [];
    assets = [
        BOND, 0;
        VALBZ, 0;
        VALE, 0;
        GS, 0;
        MS, 0;
        WFC, 0;
        XLF, 0;
    ]
}

(* Orders *)
let add_order state order =
    let open Buy_or_sell in
    {state with orders =
        List.Assoc.add state.orders order.order_id (order, false)};;

let remove_order state order_id =
    let orders = state.orders in
    let open List.Assoc in
    let present = mem orders order_id in
    if present then {state with orders = remove orders order_id}
    else warn_return "Unexisting order remove attempt" state;;

let accept_order state order_id =
    let orders = state.orders in
    let open List.Assoc in
    match find orders order_id with
    | Some (_, true) -> warn_return "Trying to accept accepted order" state
    | Some (order, _) -> {state with orders = add orders order_id (order, true)}
    | None -> warn_return "Trying to accept unexisting order" state;;

let fill_order state order_id size =
    let orders = state.orders in
    let open List.Assoc in
    let open Buy_or_sell in
    match find orders order_id with
    | Some (order, true) -> {state with orders =
        add orders order_id ({order with size = order.size - size}, true)}
    | Some (_, false) -> warn_return "Trying to fill unaccepted offer" state
    | None -> warn_return "Trying to fill unexisting order" state;;

(* Assets *)
let update_assets state symbol dir size =
    let size = size * match dir with | Buy -> 1 | Sell -> -1 in
    let assets = state.assets in
    let open List.Assoc in
    let value = find_exn assets symbol in
    {state with assets = add (List.Assoc.remove state.assets symbol) symbol (value + size)};;
