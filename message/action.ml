open Core.Std;;
open Sexplib;;
open Sexplib.Std;;
open Types;;
open Yojson.Basic;;

type action =
    | Buy of Buy_or_sell.t
    | Sell of Buy_or_sell.t
    | Cancel of Order_id.t
    | Convert of Convert.t
    | Generic of Generic.t
    | Hello
    with sexp;;

let make_generic _type order_id symbol dir price size =
    {Generic._type; order_id; symbol; dir; price; size};;

let string_of_generic_action action =
    let open Generic in
    let json = `Assoc [
        ("type", `String action._type);
        ("order_id", `Int action.order_id);
        ("symbol", `String action.symbol);
        ("dir", `String action.dir);
        ("price", `Float action.price);
        ("size", `Int action.size);
    ] in to_string json;;

let string_of_action action =
    match action with
    | Hello -> to_string (`Assoc [("type", `String "hello")])
    | Cancel v -> to_string
        (`Assoc[("type", `String "cancel"); ("order_id", `Int v.order_id)])
    | _ -> let generic = match action with
        | Buy v ->
            make_generic "add" v.order_id v.symbol "BUY" v.price v.size
        | Sell v ->
            make_generic "add" v.order_id v.symbol "SELL" v.price v.size
        | Convert v ->
            make_generic "convert" 42(* TODO order_id *) v.symbol v.dir 0. v.size
        | _ -> failwith "Exhaustiveness stub"
        in
        string_of_generic_action generic;;

