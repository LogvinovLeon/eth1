module type Strategy = sig

    val handle_message :
        write : (
            Action.action -> unit Async.Std.Deferred.t
        ) ->
        state : State.t ->
        message : Message.message ->
        State.t Async.Std.Deferred.t

    val on_connect :
        write : (
            Action.action -> unit Async.Std.Deferred.t
        ) ->
        state : State.t ->
        State.t Async.Std.Deferred.t

    val on_disconnect :
        state : State.t ->
        unit Async.Std.Deferred.t

end;;

module Make_Controller =
    functor (S : Strategy) -> struct
        open Core.Std;;
        open Async.Std;;

        let handle_data_entry ~write ~state ~data =
            let message = Message.message_of_string data in (
            print_endline (Sexp.to_string (Message.sexp_of_message message));
            let open Types.Fill in
            let state = match message with
                | Message.Fill {size;symbol;dir; _} ->
                    State.update_assets state symbol dir size
                | _ -> state
            in
            let write = fun action -> write (Action.string_of_action action) in
            S.handle_message ~write ~state ~message
            );;

        let on_connect ~team_name ~write ~state =
            (* TODO: load state *)
            write (Action.string_of_action(Action.Hello team_name))
            >>= fun () ->
                let write = fun action -> write (Action.string_of_action action) in
                S.on_connect ~write ~state;;

        let on_disconnect ~state =
            (* TODO: dump state *)
            (
                print_endline (Sexp.to_string (State.sexp_of_t state));
                S.on_disconnect ~state
            );;
    end;;
