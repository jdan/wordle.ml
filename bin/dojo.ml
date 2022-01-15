open Wordle.Seacher
open Wordle.Evaluator
open Wordle.Util

exception NoRemainingWordsException
let run target dictionary =
  (* initialize the bot *)
  let freq = frequency_of_strs dictionary in
  let rec step evaluations = function
    | [] -> raise NoRemainingWordsException
    | words ->
      (* this is the bot's move *)
      let sorted_candidates =
        filter_words2 evaluations words
        |> sorted_candidates freq
        |> List.map fst
      in (
        match sorted_candidates with
        | [] -> raise NoRemainingWordsException
        | best_guess :: remaining ->
          let evaluation = evaluate best_guess target
          in if evaluation = [Green; Green; Green; Green; Green]
          then [best_guess]
          else
            best_guess ::
            step
              ((best_guess, evaluation) :: evaluations)
              remaining
      )
  in step [] dictionary

let target = "gross"

let () =
  let dictionary = read_lines ()
  in let guesses = run target dictionary
  in
  guesses
  |> String.concat " -> "
  |> print_endline
