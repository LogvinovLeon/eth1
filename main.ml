open Core.Std;;
open Async.Std;;
open Connection;;
open Message;;

let handle_data_entry write_data data =
    let message = message_of_string data in
    (
    print_endline "-----DATA_BEGIN-----";
    print_endline (Sexp.to_string (sexp_of_message message));
    print_endline "-----DATA_END-------";
    print_endline "";
    write_data "Received"
    );;

let () =
    let command = Command.async_basic
        ~summary: "eth1 trading program"
        Command.Spec.(
            empty
            +> flag "-host" (optional_with_default "localhost" string) ~doc:"Hostname"
            +> flag "-port" (optional_with_default 80 int) ~doc:"Port"
        )
        (fun host port () -> infinite_reconnect host port handle_data_entry)
    in
    Command.run command;;

