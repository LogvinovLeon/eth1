open Yojson.Basic;;
open Util;;
open Sexplib.Std;;

type message =
    | Hello
    | Error of string
    | Reject of Types.Order_id.t
    | Trade
    | Open
    | Close
    | Book (* TODO *)
    | Ack of Types.Order_id.t
    | Fill of Types.Fill.t
    | Out of Types.Order_id.t
    with sexp;;

let string_member key json =
    member key json |> to_string;;

let int_member key json =
    member key json |> to_int;;

let symbol_member key json =
    let open Types in
    let to_symbol = function
        | "BOND" -> BOND
        | "VALBZ" -> VALBZ
        | "VALE" -> VALE
        | "GS" -> GS
        | "MS" -> MS
        | "WFC" -> WFC
        | "XLF" -> XLF
        | _ -> failwith "Unknown symbol"
    in
    member key json |> to_string |> to_symbol;;

let dir_member key json =
    let open Types in
    let to_dir = function
        | "SELL" -> Sell
        | "BUY" -> Buy
        | _ -> failwith "Unknows direction"
    in
    member key json |> to_string |> to_dir;;


let fill_of_json json =
    {Types.Fill.
    order_id = json |> int_member "order_id";
    size = json |> string_member "size" |> int_of_string;
    symbol = json |> symbol_member "symbol";
    dir = json |> dir_member "sir";
    };;

let message_of_string data =
    let json = from_string data in
    let _type = json |> string_member "type" |> String.lowercase in
    match _type with
    | "hello"  -> Hello
    | "error"  -> Error (json |> string_member "error")
    | "reject" -> Reject {order_id = json |> int_member "order_id"}
    | "trade"  -> Trade
    | "open"   -> Open
    | "close"  -> Close
    | "book"   -> Book
    | "ack"    -> Ack {order_id = json |> int_member "order_id"}
    | "fill"   -> Fill (json |>  fill_of_json)
    | "out"    -> Out {order_id = json |> int_member "order_id"}
    | _ -> failwith "Exhaustiveness stub";;
