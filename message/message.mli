open Sexplib;;
open Types;;

type message =
    | Hello
    | Error of string
    | Reject of Reject.t
    | Trade
    | Open
    | Close
    | Book of Types.Book.t
    | Ack of Order_id.t
    | Fill of Types.Fill.t
    | Out of Order_id.t
    with sexp;;

val message_of_string : string -> message;;
