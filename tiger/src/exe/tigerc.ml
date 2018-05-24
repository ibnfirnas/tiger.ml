open Printf

let () =
  let path_to_program_file = Sys.argv.(1) in
  let ic = open_in path_to_program_file in
  let lexbuf = Lexing.from_channel ic in
  let rec parse_and_print () =
    match Tiger.Lexer.token lexbuf with
    | None ->
        ()
    | Some token ->
        printf "%s\n" (Tiger.Parser.Token.to_string token);
        parse_and_print ()
  in
  parse_and_print ();
  close_in ic;