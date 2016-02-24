open Core.Std;;
open Async.Std;;
open Message;;
open Action;;
open Types;;

let handle_data_entry write_data data =
    let message = message_of_string data in
    (
    print_endline "-----DATA_BEGIN-----";
    print_endline (Sexp.to_string (sexp_of_message message));
    print_endline "-----DATA_END-------";
    print_endline "";
    write_data "Received"
    >>= fun () ->
        write_data (
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
    );;
