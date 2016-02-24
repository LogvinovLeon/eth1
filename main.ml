open Core.Std;;
open Async.Std;;
open Controller;;

let () =
    let command = Command.async_basic
        ~summary: "eth1 trading program"
        Command.Spec.(
            empty
            +> flag "-host" (optional_with_default "localhost" string)
                ~doc:"Hostname"
            +> flag "-port" (optional_with_default 25000 int)
                ~doc:"Port"
        )
        (fun host port () -> Connection.infinite_reconnect
            host port
            ~handle_data_entry
            ~on_connect
            ~on_disconnect
            ~state:State.initial)
    in
    Command.run command;;

