open State;;

val infinite_reconnect:
    string -> (* host *)
    int -> (* port *)
    ( (* read handler *)
        write: (
            string -> unit Async_unix.Import.Deferred.t
        ) ->
        state : State.t ->
        data : string ->
        State.t Async.Std.Deferred.t
    ) ->
    state : State.t ->
    'c Async.Std.Deferred.t

