open Core.Std;;
open Async.Std;;
open Message;;
open Action;;
open Types;;

let handle_data_entry ~write ~state ~data =
    let message = message_of_string data in (
    printf "%s\n" (Sexp.to_string (sexp_of_message message));
    write "Received"
    >>= fun () ->
        write (
            string_of_action (
(* https://realworldocaml.org/v1/en/html/records.html#reusing-field-names *)
                Buy {Buy_or_sell.
                    order_id = 1;
                    symbol = "BOND";
                    price = 4.2;
                    size = 42
                }
            )
        )
    >>| fun () -> state
    );;
