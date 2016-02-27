open Colors;;

let warn_return message value = (
        cprintf Yellow "%s\n" message;
        value
    )

let info_return message value = (
        cprintf Blue "%s\n" message;
        value
    )
