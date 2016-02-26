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

type size_t = int with sexp;;
type order_id_t = int with sexp;;
type price_t = float with sexp;;
type _type_t = string with sexp;;

(* TODO: Change types *)
type buy_t = int with sexp;;
type sell_t = int with sexp;;

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
        symbol : symbol_t;
        dir : dir_t;
        size : size_t;
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
        symbol : symbol_t;
        dir : dir_t;
    } with sexp
end;;

module Book = struct
    type t = {
        symbol : symbol_t;
        buy : buy_t list;
        sell : sell_t list;
    } with sexp
end;;
