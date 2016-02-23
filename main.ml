open Core.Std;;
open Async.Std;;
open Connection;;

let handle_data_entry data =
    begin
        print_endline "-----DATA_BEGIN-----";
        print_endline data;
        print_endline "-----DATA_END-------";
        print_endline "";
    end;;

let () =
    let command = Command.async_basic
        ~summary: "eth1 trading program"
        Command.Spec.(
            empty
            +> flag "-host" (required string) ~doc:"Hostname"
            +> flag "-port" (required int) ~doc:"Port"
        )
        (fun host port () -> infinite_reconnect host port handle_data_entry)
    in
    Command.run command;;

