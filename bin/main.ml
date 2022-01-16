open Wordle.Seacher
open Wordle.Evaluator
open Wordle.Util

(* Finding the word "cheat" *)
let rules =
  [ ("arose", [Yellow; Black; Black; Black; Yellow])
  ; ("telia", [Yellow; Yellow; Black; Black; Yellow])
  ; ("enact", [Yellow; Black; Yellow; Yellow; Green])
  ; ("cadet", [Green; Yellow; Black; Yellow; Green])
  ]

let () =
  let words = read_lines ()
  in let freq = frequency_of_strs words
  in
  filter_words rules words
  |> sorted_candidates freq
  |> List.iter (
    fun (word, score) ->
      word ^ " " ^ (string_of_int score) |> print_endline
  )