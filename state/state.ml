open Core.Std;;
open Sexplib.Std;;
open Types;;

type t = {(* TODO *)
    offers : int list;
    assets : (symbol_t * size_t) list;
} with sexp;;

let initial = {
    offers = [];
    assets = [
        BOND, 0;
        VALBZ, 0;
        VALE, 0;
        GS, 0;
        MS, 0;
        WFC, 0;
        XLF, 0;
    ]
}

let update_assets state symbol dir size =
    let size = size * match dir with | Buy -> 1 | Sell -> -1 in
    let assets = state.assets in
    let open List.Assoc in
    let value = find_exn assets symbol in
    {state with assets = add (List.Assoc.remove state.assets symbol) symbol (value + size)};;
