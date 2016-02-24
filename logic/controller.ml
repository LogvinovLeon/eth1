open Core.Std;;
open Async.Std;;
open Types;;

type color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White;;

let int_of_color = function
    | Black -> 0 | Red     -> 1 | Green -> 2 | Yellow -> 3
    | Blue  -> 4 | Magenta -> 5 | Cyan  -> 6 | White  -> 7;;

let cprintf color =
        ksprintf (printf
        "\027[38;5;%dm%s\027[0m" (int_of_color color));;

let handle_data_entry ~write ~state ~data =
    let message = Message.message_of_string data in (
    printf "%s\n" (Sexp.to_string (Message.sexp_of_message message));
    write (Action.string_of_action (Action.Hello))
    >>= fun () ->
        write (
            Action.string_of_action (
(* https://realworldocaml.org/v1/en/html/records.html#reusing-field-names *)
                Action.Buy {Buy_or_sell.
                    order_id = 1;
                    symbol = "BOND";
                    price = 4.2;
                    size = 42
                }
            )
        )
    >>| fun () -> state
    );;

let on_connect ~write ~state =
    (* TODO: load state *)
    write (Action.string_of_action(Action.Hello))
    >>| fun () -> state;;
