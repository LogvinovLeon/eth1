open Sexplib;;
open Sexplib.Std;;

type t = {(* TODO *)
    offers : int list
} with sexp;;

let initial = {offers = []};;

