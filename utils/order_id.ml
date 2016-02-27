let new_order_id =
    let counter = ref 0 in
    fun () ->
        begin
            counter := !counter + 1;
            !counter
        end;;

