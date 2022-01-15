open Util

type word = char list
type square = Black | Yellow | Green
type result = square list

let green_indices guess target =
  let rec inner guess target idx =
    match (guess, target) with
    | ([], _) -> []
    | (_, []) -> []
    | (g::gs, t::ts) ->
      if g = t
      then idx :: inner gs ts (idx + 1)
      else inner gs ts (idx + 1)
  in inner guess target 0

let%test _ =
  [0; 1; 2; 3; 4] = green_indices (explode "HELLO") (explode ("HELLO"))
let%test _ =
  [1; 2; 3; 4] = green_indices (explode "HELLO") (explode ("JELLO"))

let yellow_indices guess target accounted_for =
  guess
  |> List.mapi (fun idx ch -> (idx, ch))
  |> List.fold_left
    ( fun (indices, accounted_for) (idx, ch) ->
        (* TODO: no need for candidates to be an array,
           short-circuit when we find one *)
        let candidates =
          target
          |> List.mapi
            ( fun target_idx target_ch ->
                ( target_idx, target_ch )
            )
          |> List.filter (
            ( fun (target_idx, target_ch) ->
                if target_ch <> ch
                then false
                else if List.exists ((=) target_idx) accounted_for
                then false
                else true
            )
          )
          |> List.map fst
        in
        match candidates with
        | [] -> (indices, accounted_for)
        | first_yellow_idx :: _ ->
          ( List.append indices [idx]
          , List.append accounted_for [first_yellow_idx]
          )
    )
    ([], accounted_for)
  |> fst

let%test _ =
  [1; 2] = yellow_indices (explode "ALLOY") (explode "SMELL") []
let%test _ =
  [1] = yellow_indices (explode "ALLOY") (explode "SMELT") []

let evaluate guess target =
  let inner guess target =
    let greens = green_indices guess target
    in let yellows = yellow_indices guess target greens
    in List.mapi (
      fun idx _ ->
        if List.exists ((=) idx) greens
        then Green
        else if List.exists ((=) idx) yellows
        then Yellow
        else Black
    ) guess

  in inner (explode guess) (explode target)