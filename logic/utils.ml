open Core.Std;;
open Async.Std;;
open State;;

let buy ~symbol ~price ~size ~write ~state =
    let order = {Types.Buy_or_sell.
         order_id = Order_id.new_order_id ();
         symbol = symbol;
         price = price;
         size = size
        } in
    write (Action.Buy order) >>= fun () ->
    let open List.Assoc in
    return { state with buy_orders = (order.order_id, (order, false))::state.buy_orders;
                        last_orders = add (remove state.last_orders symbol) symbol (Time.now ())};;

let sell ~symbol ~price ~size ~write ~state =
    let order = {Types.Buy_or_sell.
         order_id = Order_id.new_order_id ();
         symbol = symbol;
         price = price;
         size = size
        } in
    write (Action.Sell order) >>= fun () ->
    let open List.Assoc in
    return { state with sell_orders = (order.order_id, (order, false))::state.sell_orders;
                        last_orders = add (remove state.last_orders symbol) symbol (Time.now ())};;

let cancel ~order_id ~write = write (Action.Cancel { order_id });;
