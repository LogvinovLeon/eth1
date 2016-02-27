open Yojson.Basic;;
open Util;;
open Sexplib.Std;;

type message =
    | Hello
    | Error of string
    | Reject of Types.Order_id.t
    | Trade
    | Open
    | Close
    | Book of Types.Book.t
    | Ack of Types.Order_id.t
    | Fill of Types.Fill.t
    | Out of Types.Order_id.t
    with sexp;;

let string_member key json =
    member key json |> to_string;;

let int_member key json =
    member key json |> to_int;;

let list_member key json =
    member key json |> to_list;;

let symbol_member key json =
    let open Types in
    let to_symbol = function
        | "BOND" -> BOND
        | "VALBZ" -> VALBZ
        | "VALE" -> VALE
        | "GS" -> GS
        | "MS" -> MS
        | "WFC" -> WFC
        | "XLF" -> XLF
        | _ -> failwith "Unknown symbol"
    in
    member key json |> to_string |> to_symbol;;

let dir_member key json =
    let open Types in
    let to_dir = function
        | "SELL" -> Sell
        | "BUY" -> Buy
        | _ -> failwith "Unknows direction"
    in
    member key json |> to_string |> to_dir;;


let fill_of_json json =
    {Types.Fill.
    order_id = json |> int_member "order_id";
    size = json |> int_member "size";
    symbol = json |> symbol_member "symbol";
    dir = json |> dir_member "dir";
    price = json |> int_member "price";
    };;

let price_size_of_json_array arr =
    match arr |> to_list with
      | [price; size] ->
        {Types.Price_size.
        price = to_int price;
        size = to_int size;
        }
      | _ -> failwith "illegal price_size";;

let book_of_json json =
    {Types.Book.
        symbol = json |> symbol_member "symbol";
        sell = json |> list_member "sell" |> List.map price_size_of_json_array;
        buy = json |> list_member "buy" |> List.map price_size_of_json_array;
    }

let message_of_string data =
    let json = from_string data in
    let _type = json |> string_member "type" |> String.lowercase in
    match _type with
    | "hello"  -> Hello
    | "error"  -> Error (json |> string_member "error")
    | "reject" -> Reject {Types.Order_id.order_id =
        json |> int_member "order_id"}
    | "trade"  -> Trade
    | "open"   -> Open
    | "close"  -> Close
    | "book"   -> Book (json |> book_of_json)
    | "ack"    -> Ack {Types.Order_id.
        order_id = json |> int_member "order_id"}
    | "fill"   -> Fill (json |> fill_of_json)
    | "out"    -> Out {Types.Order_id.
        order_id = json |> int_member "order_id"}
    | _ -> failwith "Exhaustiveness stub";;
