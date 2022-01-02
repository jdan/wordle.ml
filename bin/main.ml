open Wordle.Seacher

let rec read_lines () =
  let line = try
      read_line ()
    with End_of_file -> ""
  in
  if line = ""
  then []
  else line :: read_lines ()

let rules =
  [ (* SIREN *)
    Other ('s', 0)
  ; Never 'i'
  ; Never 'r'
  ; Never 'e'
  ; Never 'n'
  ]

let () =
  read_lines ()
  |> filter_words rules
  |> List.iter (print_endline)