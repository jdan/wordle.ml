open Util
open Evaluator

let rec filter_words results = function
  | [] -> []
  | words ->
    let matching_pattern guess pattern =
      List.filter (
        fun candidate ->
          evaluate guess candidate = pattern
      )
    in ( match results with
        | [] -> words
        | (guess, pattern)::rest ->
          matching_pattern guess pattern words
          |> filter_words rest
      )

let frequency_of_str str =
  let tbl = Hashtbl.create 40 in
  let char_list = explode str in
  List.iter
    ( fun ch ->
        if Hashtbl.mem tbl ch
        then
          Hashtbl.replace tbl ch (1 + Hashtbl.find tbl ch)
        else
          Hashtbl.add tbl ch 1
    )
    char_list ;
  (* Return the table *)
  tbl

let frequency_of_strs =
  let combine_mut a b =
    Hashtbl.iter
      ( fun ch count ->
          if Hashtbl.mem a ch
          then Hashtbl.replace a ch (count + Hashtbl.find a ch)
          else Hashtbl.add a ch count
      )
      b ;
    a
  in List.fold_left (
    fun tbl str -> (
        combine_mut tbl (frequency_of_str str)
      )
  ) (Hashtbl.create 40)

(* Simple heuristic to "score" a word *)
let score freq str =
  let chars = explode str in
  let num_unique =
    List.sort_uniq
      ( fun a b -> Char.code a - Char.code b)
      chars
    |> List.length
  in
  List.fold_left
    ( fun total ch ->
        total + Hashtbl.find freq ch
    )
    0
    chars
  * num_unique

let sorted_candidates freq strs =
  let with_scores =
    List.map (fun str -> (str, score freq str)) strs
  in List.sort
    ( fun (_, a) (_, b) ->
        b - a
    )
    with_scores