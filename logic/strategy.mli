open State;;

val handle_data_entry :
    write : (
        string -> unit Async.Std.Deferred.t
    ) ->
    state : State.t ->
    data : string ->
    State.t Async.Std.Deferred.t

val on_connect :
    write : (
        string -> unit Async.Std.Deferred.t
    ) ->
    state : State.t ->
    State.t Async.Std.Deferred.t

val on_disconnect :
    state : State.t ->
    unit Async.Std.Deferred.t
