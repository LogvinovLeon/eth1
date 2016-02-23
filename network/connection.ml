open Core.Std;;
open Async.Std;;

let with_connection host port f =
    let addr = Tcp.to_host_and_port host port in
    Tcp.with_connection addr f;;

let read_data_entry reader =
    Reader.read_line reader >>| function
        | `Ok s -> s
        | `Eof  -> raise End_of_file;;

let rec main_loop handle_data_entry s r w =
    read_data_entry r
    >>| handle_data_entry
    >>= fun () -> main_loop handle_data_entry s r w;;

let rec infinite_reconnect host port handle_data_entry =
    try_with (fun () ->
        with_connection "localhost" 80 (main_loop handle_data_entry))
    >>= function
        | Ok _ -> failwith "Connection finised with OK"
        | Error _ -> (
            let delay = Time.Span.of_sec 0.5 in
            Clock.after delay
            >>= fun () -> (
                let delay_sexp = Time.Span.sexp_of_t delay in
                let delay_s = Sexp.to_string delay_sexp in
                printf "Reconnecting after %s ...\n" delay_s;
                infinite_reconnect host port handle_data_entry
            )
        );;

