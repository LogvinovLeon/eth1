open Async.Std;;

(* Change strategy here *)
(* Required signature is in logic/controller.ml *)
module C = Controller.Make_Controller (Moving_average);;

let () =
    let command = Command.async_basic
        ~summary: "eth1 trading program"
        Command.Spec.(
            empty
            +> flag "-host" (optional_with_default "localhost" string)
                ~doc:"Hostname"
            +> flag "-port" (optional_with_default 25000 int)
                ~doc:"Port"
            +> flag "-name" (optional_with_default "TEAM_NAME" string)
                ~doc:"Team name"
        )
        (fun host port team_name () -> Connection.infinite_reconnect
                host
                port
                ~handle_data_entry:C.handle_data_entry
                ~on_connect:(C.on_connect ~team_name)
                ~on_disconnect:C.on_disconnect
                ~state:State.initial
        )
    in
    Command.run command;;

