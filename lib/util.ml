let explode s = String.to_seq s |> List.of_seq

let rec read_lines () =
  let line = try
      read_line ()
    with End_of_file -> ""
  in
  if line = ""
  then []
  else line :: read_lines ()