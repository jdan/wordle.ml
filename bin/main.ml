open Wordle.Seacher
open Wordle.Evaluator
open Wordle.Util

(* Finding the word "great" *)
let rules =
  [ ("aeros", [Yellow; Yellow; Yellow; Black; Black])
  ; ("raile", [Yellow; Yellow; Black; Black; Yellow])
  ; ("tread", [Yellow; Green; Green; Green; Black])
  ]

let () =
  let words = read_lines ()
  in let freq = frequency_of_strs words
  in
  filter_words2 rules words
  |> sorted_candidates freq
  |> List.iter (
    fun (word, score) ->
      word ^ " " ^ (string_of_int score) |> print_endline
  )