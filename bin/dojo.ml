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
    { freq = frequency_of_strs dictionary
    ; candidates = dictionary
    ; history = []
    }

  let guess { freq; candidates; history } =
    match (
      filter_words2 history candidates
      |> sorted_candidates freq
    ) with
    | [] -> raise NoRemainingWordsException
    | (best, _) :: _ -> best

  let update ({history; _} as me) attempt result =
    (* TODO: trim down candidates *)
    { me with
      history = (attempt, result) :: history
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
