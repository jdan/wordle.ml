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

  let run_all dictionary =
    let bot = B.initialize dictionary
    in List.map
      ( fun word -> run bot word )
      dictionary

  let run_sampled dictionary count =
    let bot = B.initialize dictionary
    in
    List.init count (fun _ -> Random.int (List.length dictionary))
    |> List.map (fun idx -> List.nth dictionary idx)
    |> List.map
      ( fun word -> run bot word )

  let average dictionary =
    let num_guesses = run_all dictionary |> List.map (List.length)
    in
    (List.fold_left (+) 0 num_guesses |> float_of_int)
    /. (List.length dictionary |> float_of_int)
end

module GreedyAdieuBot : Bot = struct
  type t =
    { count : int
    ; greedy : GreedyBot.t
    }
  let initialize dictionary =
    { count = 0
    ; greedy = GreedyBot.initialize dictionary
    }
  let guess {count; greedy} =
    if count = 0
    then "adieu"
    else GreedyBot.guess greedy
  let update {count; greedy} guess result =
    { count = count + 1
    ; greedy = GreedyBot.update greedy guess result
    }
end

module GreedyAdieuUnityBot : Bot = struct
  type t =
    { count : int
    ; greedy : GreedyBot.t
    }
  let initialize dictionary =
    { count = 0
    ; greedy = GreedyBot.initialize dictionary
    }
  let guess {count; greedy} =
    if count = 0
    then "adieu"
    else if count = 1
    then "unity"
    else GreedyBot.guess greedy
  let update {count; greedy} guess result =
    { count = count + 1
    ; greedy = GreedyBot.update greedy guess result
    }
end

(* 4.9835800185 *)
module GreedyRunner = Runner (GreedyBot)

(* 5.01896392229 *)
module GreedyAdieuRunner = Runner (GreedyAdieuBot)

(* 5.30226641998 *)
module GreedyAdieuUnityRunner = Runner (GreedyAdieuUnityBot)

(*
  let () =
    let dictionary = read_lines ()
    in
    GreedyRunner.average dictionary
    |> string_of_float
    |> print_endline

  $ time cat words.txt | dune exec bin/dojo.exe
  4.9835800185
  cat words.txt  0.00s user 0.00s system 7% cpu 0.076 total
  dune exec bin/dojo.exe  97.13s user 0.15s system 99% cpu 1:37.28 total
*)

let () =
  let dictionary = read_lines ()
  in
  Random.init 1000 ;
  GreedyAdieuRunner.run_sampled dictionary 10
  |> List.map (String.concat " -> ")
  |> String.concat "\n"
  |> print_endline
(* GreedyAdieuUnityRunner.average dictionary
   |> string_of_float
   |> print_endline *)
