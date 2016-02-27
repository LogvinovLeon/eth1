open Warnings;;

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
            let message = info_return ("received " ^ data) (Message.message_of_string data) in (
            print_endline (Sexp.to_string (Message.sexp_of_message message));
            let open Types.Fill in
            let state = match message with
                | Message.Fill f ->
                    State.fill_order
                        (State.update_assets state f.symbol f.dir f.size)
                        f.order_id
                        f.size
                | Message.Book book -> State.add_book state book
                | Message.Ack o -> State.accept_order state o.order_id
                | Message.Reject o ->
                        warn_return ("order rejected: " ^ o.reason)
                            (State.remove_order state o.order_id)
                | Message.Out o -> State.remove_order state o.order_id;
                | Message.Error e -> warn_return ("error: " ^ e) state;
                | Message.Open -> State.initial
                | Message.Close -> { state with closed = true }
                | _ -> state
            in
            let write = fun action ->
                let str = Action.string_of_action action in info_return ("sending " ^ str) (write str) in
            if state.closed then
                return state
            else
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
