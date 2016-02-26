open Core.Std;;
open Sexplib.Std;;
open Types;;
open Warnings;;
open List.Assoc;;

type t = {(* TODO: add more values *)
    orders : (order_id_t * (Buy_or_sell.t * bool (* Is accepted *))) list;
    assets : (symbol_t * size_t) list;
    books : (symbol_t * Book.t list) list; (* Newest first *)
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
    ];
    books = [
        BOND, [];
        VALBZ, [];
        VALE, [];
        GS, [];
        MS, [];
        WFC, [];
        XLF, [];
    ]
}

(* Books *)
let add_book state book =
    (* TODO: Maybe remove old books *)
    let open Book in
    match find state.books book.symbol with
    | Some type_books -> {state with books =
        add state.books book.symbol (book::type_books)}
    | None -> warn_return "Trying to add a book of unknown symbol" state;;

let get_current_book state symbol =
    match find state.books symbol with
    | Some books -> List.nth books 0
    | None -> warn_return "Unknown symbol" None;;

let get_prev_book state symbol =
    match find state.books symbol with
    | Some books -> List.nth books 1
    | None -> warn_return "Unknown symbol" None;;

(* Orders *)
let add_order state order =
    let open Buy_or_sell in
    {state with orders =
        add state.orders order.order_id (order, false)};;

let remove_order state order_id =
    let orders = state.orders in
    match mem orders order_id with
    | true -> {state with orders = remove orders order_id}
    | _ -> warn_return "Unexisting order remove attempt" state;;

let accept_order state order_id =
    let orders = state.orders in
    match find orders order_id with
    | Some (_, true) -> warn_return "Trying to accept accepted order" state
    | Some (order, _) -> {state with orders = add orders order_id (order, true)}
    | None -> warn_return "Trying to accept unexisting order" state;;

let fill_order state order_id size =
    let orders = state.orders in
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
    let value = find_exn assets symbol in
    {state with assets = add (remove state.assets symbol) symbol (value + size)};;
