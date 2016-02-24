open Core.Std;;
open Async.Std;;

type color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White;;

let int_of_color = function
    | Black -> 0 | Red     -> 1 | Green -> 2 | Yellow -> 3
    | Blue  -> 4 | Magenta -> 5 | Cyan  -> 6 | White  -> 7;;

let cprintf color =
    ksprintf (printf "\027[38;5;%dm%s\027[0m" (int_of_color color));;
