open Core.Std;;
open Async.Std;;

type color = Black | Red | Green | Yellow | Blue | Magenta | Cyan | White;;

val cprintf : color -> ('a, unit, string, unit) format4 -> 'a;;
