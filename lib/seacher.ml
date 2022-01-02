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
