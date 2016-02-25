open Sexplib;;
open Sexplib.Std;;
open Yojson.Basic;;

type action =
    | Buy of Types.Buy_or_sell.t
    | Sell of Types.Buy_or_sell.t
    | Cancel of Types.Order_id.t
    | Convert of Types.Convert.t
    | Generic of Types.Generic.t
    | Hello of string
    with sexp;;

let make_generic _type order_id symbol dir price size =
    {Types.Generic._type; order_id; symbol; dir; price; size};;

let string_of_symbol symbol =
    let open Types in
    match symbol with
    | BOND -> "BOND"
    | VALBZ -> "VALBZ"
    | VALE -> "VALE"
    | GS -> "GS"
    | MS -> "MS"
    | WFC -> "WFC"
    | XLF -> "XLF";;

let string_of_dir dir =
    match dir with
    | Types.Sell -> "SELL"
    | Types.Buy -> "BUY";;

let string_of_generic_action action =
    (* TODO: Check types vs actual specification *)
    let open Types.Generic in
    let json = `Assoc [
        ("type", `String action._type);
        ("order_id", `Int action.order_id);
        ("symbol", `String (string_of_symbol action.symbol));
        ("dir", `String (string_of_dir action.dir));
        ("price", `Float action.price);
        ("size", `Int action.size);
    ] in to_string json;;

let string_of_action action =
    match action with
    | Hello name -> to_string
        (`Assoc [("type", `String "hello"); ("team", `String name)])
    | Cancel v -> to_string
        (`Assoc[("type", `String "cancel"); ("order_id", `Int v.order_id)])
    | _ -> let generic = match action with
        | Buy v ->
            make_generic "add" v.order_id v.symbol Buy v.price v.size
        | Sell v ->
            make_generic "add" v.order_id v.symbol Sell v.price v.size
        | Convert v ->
            make_generic "convert" 42(* TODO order_id *) v.symbol v.dir 0. v.size
        | _ -> failwith "Exhaustiveness stub"
        in
        string_of_generic_action generic;;

