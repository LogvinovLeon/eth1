open Sexplib;;
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

val message_of_string : string -> message;;
