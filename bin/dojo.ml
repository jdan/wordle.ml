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

let run target dictionary =
  let rec step bot =
    let guess = GreedyBot.guess bot
    in let evaluation = evaluate guess target
    in if evaluation = [Green; Green; Green; Green; Green]
    then [guess]
    else
      guess :: step (GreedyBot.update bot guess evaluation)
  in step (GreedyBot.initialize dictionary)

let target = "hatch"

let () =
  let dictionary = read_lines ()
  in let guesses = run target dictionary
  in
  guesses
  |> String.concat " -> "
  |> print_endline
