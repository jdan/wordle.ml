open Util
open Evaluator

type rule =
  | Exact of char * int
  | Other of char * int
  | Never of char
  | AtLeast of char * int

let predicate_of_rule = function
  | Exact (c, idx) ->
    fun str -> String.get str idx = c
  | Other (c, idx) ->
    fun str -> (
        match String.index_from_opt str 0 c with
        | None -> false
        | Some found_idx -> idx <> found_idx
      )
  | Never c -> fun str -> (
      String.index_from_opt str 0 c
      |> Option.is_none
    )
  | AtLeast (c, count) -> fun str -> (
      ( explode str
        |> List.filter ((=) c)
        |> List.length
      )
      >= count
    )

let rec predicate_of_rules rules str =
  match rules with
  | [] -> true
  | x::xs ->
    predicate_of_rule x str
    && predicate_of_rules xs str

let filter_words rules =
  predicate_of_rules rules
  |> List.filter

let%test _ =
  filter_words
    [ Exact ('a', 0) ]
    ["abc"; "def"; "afe"]
  = ["abc"; "afe"]

let%test _ =
  filter_words
    [ Exact ('a', 0); Never 'f' ]
    ["abc"; "def"; "aef"]
  = ["abc"]

let%test _ =
  filter_words
    [ Exact ('a', 0)
    ; Other ('e', 1)
    ]
    ["abc"; "def"; "afe"]
  = ["afe"]

let%test _ =
  filter_words
    [ Other ('f', 0)
    ; Other ('e', 0)
    ]
    ["abc"; "def"; "afe"]
  = ["def"; "afe"]

let%test "Multiple `Other`s do not denote repeats" =
  filter_words
    [ Other ('l', 0)
    ; Other ('l', 1)
    ]
    ["hall"; "bail"]
  = ["hall"; "bail"]

(* It would be nice to filter out `bail` when we know
   we have two L's, but Other is not precise enough
*)
let%test _ =
  filter_words
    [ Other ('l', 0)
    ; Other ('l', 1)
    ; AtLeast ('l', 2)
    ]
    ["hall"; "bail"; "parallel"]
  = ["hall"; "parallel"]

(* Improved filter using Evaluator *)
let rec filter_words2 results = function
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
          |> filter_words2 rest
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