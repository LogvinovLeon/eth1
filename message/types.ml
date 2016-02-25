open Sexplib.Std;;

type size_t = string;;
type order_id_t = int;;
type dir_t = string;;
type price_t = float;;
type symbol_t = string;;
type _type_t = string;;

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

