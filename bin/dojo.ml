open Wordle.Seacher
open Wordle.Evaluator
open Wordle.Util

module type Bot = sig
  type t
  val initialize : string list -> t
  val guess : t -> string
  val update : t -> string -> result -> t
end

exception NoRemainingWordsException

module GreedyBot : Bot = struct
  type t =
    { freq : (char, int) Hashtbl.t
    ; candidates : string list
    ; history : (string * result) list
    }

  let initialize dictionary =
    let freq = frequency_of_strs dictionary
    in
    { freq = freq
    ; candidates =
        filter_words2 [] dictionary
        |> sorted_candidates freq
        |> List.map fst
    ; history = []
    }

  let guess { candidates; _ } =
    match candidates with
    | [] -> raise NoRemainingWordsException
    | best::_ -> best

  let update {history; freq; candidates} attempt result =
    let new_history = (attempt, result) :: history
    in
    { freq = freq
    ; candidates =
        filter_words2 new_history candidates
        |> sorted_candidates freq
        |> List.map fst
    ;  history = new_history
    }
end

module Runner (B : Bot) = struct
  let rec run bot target =
    let guess = B.guess bot
    in let evaluation = evaluate guess target
    in if evaluation = [Green; Green; Green; Green; Green]
    then [guess]
    else
      guess :: run (B.update bot guess evaluation) target

  let average dictionary =
    let bot = B.initialize dictionary
    in let num_guesses =
         List.map
           ( fun word -> run bot word |> List.length )
           dictionary
    in (List.fold_left (+) 0 num_guesses |> float_of_int)
       /. (List.length dictionary |> float_of_int)
end

let target = "hatch"
module GreedyRunner = Runner (GreedyBot)

let () =
  let dictionary = read_lines ()
  in GreedyRunner.average dictionary |> string_of_float |> print_endline
(* in let guesses = GreedyRunner.run target dictionary
   in
   guesses
   |> String.concat " -> "
   |> print_endline *)
