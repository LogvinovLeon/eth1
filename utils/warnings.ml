open Colors;;

let warn_return message value = (
        cprintf Yellow "%s\n" message;
        value
    )
