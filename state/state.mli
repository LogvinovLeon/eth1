open Types;;

type t with sexp;;

val initial : t;;

(* Books *)
val add_book : t -> Types.Book.t -> t

val get_current_book : t -> Types.symbol_t -> Types.Book.t option

(* Orders *)
val add_order : t -> Types.Buy_or_sell.t -> t

val remove_order : t -> Types.order_id_t -> t

val accept_order : t -> Types.order_id_t -> t

val fill_order : t -> Types.order_id_t -> int -> t

(* Assets *)
val update_assets : t -> symbol_t -> dir_t -> int -> t
