open Core.Std;;
open Async.Std;;

let handle_message ~write ~state ~message =
    return state;;

let on_connect ~write ~state =
    return state;;

let on_disconnect ~state =
    return ();;

