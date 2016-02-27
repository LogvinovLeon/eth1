open Core.Std;;
open Sexplib.Std;;
open Types;;
open Warnings;;
open List.Assoc;;

type t = {(* TODO: add more values *)
    buy_orders : (order_id_t * (Buy_or_sell.t * bool (* Is accepted *))) list;
    sell_orders : (order_id_t * (Buy_or_sell.t * bool (* Is accepted *))) list;
    assets : (symbol_t * size_t) list;
    books : (symbol_t * Book.t list) list; (* Newest first *)
    last_orders : (symbol_t * Time.t) list;
    closed : bool;
} with sexp;;

let initial () = let now = Time.now () in {
    buy_orders = [];
    sell_orders = [];
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
    ];
    last_orders = [
        BOND, now;
        VALBZ, now;
        VALE, now;
        GS, now;
        MS, now;
        WFC, now;
        XLF, now;
    ];
    closed = false;
}

(* Books *)
let add_book state book =
    (* TODO: Maybe remove old books *)
    let open Book in
    match find state.books book.symbol with
    | Some type_books -> {state with books =
        add state.books book.symbol (List.take (book::type_books) 256)}
    | None -> warn_return "Trying to add a book of unknown symbol" state;;

let get_current_book state symbol =
    match find state.books symbol with
    | Some books -> List.nth books 0
    | None -> warn_return "Unknown symbol" None;;

let get_prev_book state symbol =
    match find state.books symbol with
    | Some books -> List.nth books 1
    | None -> warn_return "Unknown symbol" None;;

let get_highest_buy state symbol =
    let open List.Assoc in
    match get_current_book state symbol with
    | Some book -> List.nth (List.map ~f:(fun x -> x.price) book.buy) 0
    | None -> None;;

let get_lowest_sell state symbol =
    let open List.Assoc in
    match get_current_book state symbol with
    | Some book -> List.nth (List.map ~f:(fun x -> x.price) book.sell) 0
    | None -> None;;

(* Orders *)
let add_buy_order state order =
    let open Buy_or_sell in
    {state with buy_orders =
        add state.buy_orders order.order_id (order, false)};;

let add_sell_order state order =
    let open Buy_or_sell in
    {state with sell_orders =
        add state.sell_orders order.order_id (order, false)};;

let remove_order state order_id =
    let state =
        (match mem state.buy_orders order_id with
        | true -> {state with buy_orders = remove state.buy_orders order_id}
        | _ -> state)
    in
        (match mem state.sell_orders order_id with
        | true -> {state with sell_orders = remove state.sell_orders order_id}
        | _ -> state);;

let accept_order state order_id =
    let state =
        match find state.buy_orders order_id with
        | Some (_, true) -> warn_return "Trying to accept accepted order" state
        | Some (order, _) -> {state with buy_orders = add state.buy_orders order_id (order, true)}
        | _ -> state
    in
        match find state.sell_orders order_id with
        | Some (_, true) -> warn_return "Trying to accept accepted order" state
        | Some (order, _) -> {state with sell_orders = add state.sell_orders order_id (order, true)}
        | _ -> state;;

let _fill_order orders order_id size =
    let open Buy_or_sell in
    match find orders order_id with
    | Some (order, true) -> add orders order_id ({order with size = order.size - size}, true)
    | Some (_, false) -> warn_return "Trying to fill unaccepted offer" orders
    | _ -> orders;;


let fill_order state order_id size =
    let open Buy_or_sell in
    {state with
        buy_orders = _fill_order state.buy_orders order_id size;
        sell_orders = _fill_order state.sell_orders order_id size
    };;

let get_buy_order state symbol =
    let open List.Assoc in
    let open Buy_or_sell in
    List.nth (
        List.map ~f:(fun (order_id, (order, _)) -> order)
        (List.filter ~f:(fun (order_id,(order, _)) -> order.symbol = symbol) state.buy_orders)) 0;;

let get_sell_order state symbol =
    let open List.Assoc in
    let open Buy_or_sell in
    List.nth (
        List.map ~f:(fun (order_id, (order, _)) -> order)
        (List.filter ~f:(fun (order_id,(order, _)) -> order.symbol = symbol) state.sell_orders)) 0;;

(* Assets *)
let update_assets state symbol dir size =
    let size = size * match dir with | Buy -> 1 | Sell -> -1 in
    let assets = state.assets in
    let value = find_exn assets symbol in
    {state with assets = add (remove state.assets symbol) symbol (value + size)};;
