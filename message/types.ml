open Sexplib;;
open Sexplib.Std;;

module Order_id = struct
    type t = {order_id : int} with sexp
end;;

module Buy_or_sell = struct
    type t = {
        order_id : int;
        symbol : string;
        price : float;
        size: int
    } with sexp
end;;

module Convert = struct
    type t = {
        symbol : string;
        dir : string;
        size : int
    } with sexp
end;;

module Generic = struct
    type t = {
        _type : string;
        order_id : int;
        symbol : string;
        dir : string;
        price : float;
        size : int
    } with sexp
end;;

module Fill = struct
    type t = {
        order_id: int;
        size : int;
        symbol : string;
        dir : string
    } with sexp
end;;

