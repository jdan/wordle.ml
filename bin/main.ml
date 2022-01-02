open Wordle.Seacher

let rules =
  [ Other ('a', 0)
  ; Never 'r'
  ; Never 'o'
  ; Never 's'
  ; Other ('e', 4)
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
  let words = read_lines ()
  in let freq = frequency_of_strs words
  in
  filter_words rules words
  |> sorted_candidates freq
  |> List.iter (
    fun (word, score) ->
      word ^ " " ^ (string_of_int score) |> print_endline
  )