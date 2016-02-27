open Sexplib.Std;;

type symbol_t =
    | BOND
    | VALBZ
    | VALE
    | GS
    | MS
    | WFC
    | XLF
    with sexp;;

type dir_t =
    | Buy
    | Sell
    with sexp;;

let negate = function
    | Buy -> Sell
    | Sell -> Buy;;

type size_t = int with sexp;;
type order_id_t = int with sexp;;
type price_t = int with sexp;;
type _type_t = string with sexp;;

module Price_size = struct
    type t = {
        price : price_t;
        size : int;
    } with sexp
end;;

module Order_id = struct
    type t = {order_id : order_id_t} with sexp
end;;

module Buy_or_sell = struct
    type t = {
        order_id : order_id_t;
        symbol : symbol_t;
        price : price_t;
        size: size_t;
    } with sexp
end;;

module Convert = struct
    type t = {
        order_id : order_id_t;
        symbol : symbol_t;
        dir : dir_t;
        size : size_t;
    } with sexp
end;;

module Reject = struct
    type t = {
        order_id : order_id_t;
        reason : string;
    } with sexp
end;;

module Generic = struct
    type t = {
        _type : _type_t;
        order_id : order_id_t;
        symbol : symbol_t;
        dir : dir_t;
        price : price_t;
        size : size_t;
    } with sexp
end;;

module Fill = struct
    type t = {
        order_id: order_id_t;
        size : size_t;
        price : price_t;
        symbol : symbol_t;
        dir : dir_t;
    } with sexp
end;;

module Book = struct
    type t = {
        symbol : symbol_t;
        buy : Price_size.t list;
        sell : Price_size.t list;
    } with sexp
end;;

module Trade = struct
    type t = {
        symbol : symbol_t;
        price : price_t;
        size : size_t;
    } with sexp
end;;
