(* Compiler
    - Consumes semantically analyzed syntax tree from semantic analyzer
    - Produces compiled program
 *)

type action = Ast | Sast | Gen | Debug

let _ =
  let action =
    List.assoc Sys.argv.(1) [("-a", Ast); ("-s", Sast); ("-g", Gen); ("-d", Debug);]
  in
    let lexbuf = Lexing.from_channel stdin in
      let program = Parser.stmt_list Scanner.token lexbuf in
        match action with 
          Ast ->  print_string (Ast.string_of_stmts program)
          | Sast -> print_string (Ast.string_of_stmts program)
          | Gen -> print_string (Ast.string_of_stmts program)
          | Debug -> print_string (Ast.string_of_stmts program)
