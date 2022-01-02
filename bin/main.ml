open Wordle.Seacher

let rules =
  [ (* SIREN *)
    Other ('s', 0)
  ; Never 'i'
  ; Never 'r'
  ; Never 'e'
  ; Never 'n'

  (* AULOS *)
  ; Never 'a'
  ; Never 'u'
  ; Never 'l'
  ; Other ('o', 3)
  ; Other ('s', 4)
  ]

let rec read_lines () =
  let line = try
      read_line ()
    with End_of_file -> ""
  in
  if line = ""
  then []
  else line :: read_lines ()

let () =
  read_lines ()
  |> filter_words rules
  |> sorted_candidates
  |> List.iter (
    fun (word, score) ->
      word ^ " " ^ (string_of_int score) |> print_endline
  )