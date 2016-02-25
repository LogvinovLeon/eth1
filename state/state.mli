open Types;;

type t = {
    offers : int list;
    assets : (symbol_t * size_t) list;
} with sexp;;

val initial : t;;

val update_assets : t -> symbol_t -> dir_t -> int -> t
