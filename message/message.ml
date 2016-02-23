open Yojson.Basic;;
open Util;;
open Sexplib;;
open Sexplib.Std;;

type order_id = {order_id : int} with sexp;;

type message =
    | Hello
    | Error of string
    | Reject of order_id
    | Trade
    | Open
    | Close
    | Book (* TODO *)
    | Ack of order_id
    | Fill (* TODO *)
    | Out of order_id
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
    | _ -> Error ("Parsing not implemented yet")
