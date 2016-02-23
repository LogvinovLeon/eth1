open Yojson.Basic;;
open Util;;
open Sexplib;;
open Sexplib.Std;;

type message =
    | Hello
    | Error of string
    | Reject of int
    | Trade
    | Open
    | Close
    | Book
    | Ack of int
    | Fill
    | Out of int
    with sexp;;

let string_member key json =
    member key json |> to_string;;

let message_of_string data =
    let json = from_string data in
    let _type = json |> string_member "type" |> String.lowercase in
    match _type with
    | "hello" -> Hello
    | _ -> Error (json |> string_member "error");;
