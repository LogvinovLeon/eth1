open Yojson.Basic;;
open Util;;
open Sexplib.Std;;
open Types;;

type message =
    | Hello
    | Error of string
    | Reject of Order_id.t
    | Trade
    | Open
    | Close
    | Book (* TODO *)
    | Ack of Order_id.t
    | Fill (* TODO *)
    | Out of Order_id.t
    with sexp;;

let string_member key json =
    member key json |> to_string;;

let int_member key json =
    member key json |> to_int;;

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
    | "fill"   -> Fill
    | "out"    -> Out {order_id = json |> int_member "order_id"}
    | _ -> failwith "Exhaustiveness stub";;
