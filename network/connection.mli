open State;;

type writer = string -> unit Async_unix.Import.Deferred.t;;

val infinite_reconnect:
    string -> (* host *)
    int -> (* port *)
    handle_data_entry : (
        write: writer ->
        state : State.t ->
        data : string ->
        State.t Async.Std.Deferred.t
    ) ->
    on_connect : (
        write : writer ->
        state : State.t ->
        State.t Async.Std.Deferred.t
    ) ->
    state : State.t ->
    'c Async.Std.Deferred.t

