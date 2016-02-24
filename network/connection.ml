open Core.Std;;
open Async.Std;;

let with_connection host port f =
    let addr = Tcp.to_host_and_port host port in
    Tcp.with_connection addr f;;

let read_data_entry reader =
    Reader.read_line reader >>| function
        | `Ok s -> s
        | `Eof  -> raise End_of_file;;

let write_data_entry writer data = (
    Writer.write_line writer data;
    Writer.flushed writer
);;

let main_loop handle_data_entry state _ r w =
    let write = write_data_entry w in
    let rec _main_loop state =
        read_data_entry r
        >>= fun data -> handle_data_entry ~write ~state ~data
        >>= fun state -> _main_loop state
    in
    _main_loop state;;

let infinite_reconnect host port handle_data_entry ~state =
    let rec _infinite_reconnect () =
        try_with (fun () ->
            with_connection host port (main_loop handle_data_entry state))
        >>= function
            | Ok _ -> failwith "Connection finised with OK"
            | Error e -> (
                print_endline (Exn.to_string e);
                let delay = Time.Span.of_sec 0.5 in
                Clock.after delay
                >>= fun () -> (
                    let delay_sexp = Time.Span.sexp_of_t delay in
                    let delay_s = Sexp.to_string delay_sexp in
                    printf "Reconnecting after %s ...\n" delay_s;
                    _infinite_reconnect ()
               )
            )
    in
    _infinite_reconnect ();;

