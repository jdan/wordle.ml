type rule =
  | Exact of char * int
  | Other of char * int
  | Never of char

let predicate_of_rule = function
  | Exact (c, idx) ->
    fun str -> (
        match String.index_from_opt str 0 c with
        | None -> false
        | Some found_idx -> idx = found_idx
      )
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

(* http://caml.inria.fr/pub/old_caml_site/FAQ/FAQ_EXPERT-eng.html#strings *)
let explode s =
  let rec exp i l =
    if i < 0 then l else exp (i - 1) (s.[i] :: l) in
  exp (String.length s - 1) []

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