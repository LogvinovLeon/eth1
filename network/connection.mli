val infinite_reconnect:
    string -> (* host *)
    int -> (* port *)
    ( (* read handler *)
        ( (* writer *)
            string -> unit Async_unix.Import.Deferred.t
        ) ->
        string -> (* data *)
        unit Async.Std.Deferred.t
    ) ->
    'c Async.Std.Deferred.t

