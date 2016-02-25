open Types;;
open Sexplib;;

type action =
    | Buy of Buy_or_sell.t
    | Sell of Buy_or_sell.t
    | Cancel of Order_id.t
    | Convert of Convert.t
    | Generic of Generic.t
    | Hello of string
    with sexp;;

val string_of_action : action -> string;;
