open Sast
open Printf
open String

(* type_of from Sast *)
let type_of (a : Sast.expr_wrapper) : Sast.sdata_type =
    match a with
    | Expr(_,t)-> t

(* expression from the expression wrapper *)
let expr_of (a : Sast.expr_wrapper) : Sast.sexpr =
    match a with
    | Expr(e,_)-> e

(* conversion type from qlang to target program*)
let cpp_from_type (ty: Sast.sdata_type) : string =
    match ty with
    | Int -> "int"
    | Float -> "float"
    | Comp -> "complex<float>"
    | Mati -> "MatrixXcf"
    | Matf -> "MatrixXcf"
    | Matc -> "MatrixXcf"
    | Qubb -> "MatrixXcf"
    | Qubk -> "MatrixXcf"
    | Void -> " "

(* write program in .cpp outfile*)
let rec writeToFile fileName progString =
    let file = open_out (fileName ^ ".cpp") in
        fprintf file "%s" progString 

(* entry point for code generation*)        
and gen_program fileName prog =
    let cppString = writeCpp prog in
    let out = sprintf "
        #include <Eigen/Dense>
        #include <cmath>
        #include <complex>
        #include <iostream>
        #include \"../../cpp/qlang.hpp\"
        using namespace Eigen;
        using namespace std;
        %s" cppString in 
    writeToFile fileName out;

(* list of function declaration*)    
and writeCpp funcList =
    let outStr = List.fold_left (fun a b -> a ^ (cpp_funcList b)) "" funcList in
    sprintf "%s" outStr

(* for each function in the list *)    
and cpp_funcList func =
    let cppRtnType = cpp_from_type func.sret_typ
    and cppRtnValue = func.sret_name
    and cppFName = func.sfunc_name
    and cppFParam = if (func.sformal_params = []) then "" else cppVarDecl func.sformal_params ","
    and cppFBody = cppStmtList func.sbody 
    and cppLocals = cppVarDecl func.slocals ";\n\t" in
    if cppFName = "compute" then
                sprintf "\nint main ()\n{\n\t%s\n\t%s\n\tstd::cout << %s << endl;\n\n\treturn 0;\n}" cppLocals cppFBody cppRtnValue
    else 
    sprintf "\n%s %s (%s)\n{\n\t%s\n\t%s\n\treturn %s;\n}" cppRtnType cppFName cppFParam cppLocals cppFBody cppRtnValue

(* variable declarations *)
and cppVarDecl vardeclist delim =
   let varDecStr = List.fold_left (fun a b -> a ^ (cppVar b delim)) "" vardeclist in
   let varDectrun = String.sub varDecStr 0 ((String.length varDecStr)-1) in
   sprintf "%s " varDectrun

(* each varibale *)   
and cppVar var delim =
    if not var.builtin then
        let vartype = cpp_from_type var.styp in 
        sprintf "%s %s%s" vartype var.sname delim
    else ""

(* list of statements *)
and cppStmtList astmtlist =    
    let outStr = List.fold_left (fun a b -> a ^ (cppStmt b)) "" astmtlist in
    sprintf "%s" outStr

(* For generating statements *)
and cppStmt stmts = match stmts with
    Sast.Sexpr(expr_wrap) -> "\t" ^ cppExpr (expr_of expr_wrap) ^ ";\n"  
  | Sast.Block(sstmt) -> cppStmtBlock sstmt
  | Sast.If(expr_wrap , sstmt1, sstmt2) -> writeIfStmt (expr_of expr_wrap) sstmt1 sstmt2
  | Sast.For(var,init, final, increment, stmt) -> writeForStmt var init final increment stmt
  | Sast.While(expr_wrap , sstmt) -> writeWhileStmt (expr_of expr_wrap) sstmt

(* For generating expressions*)
and cppExpr expr = match expr with
    Lit_int(lit) -> string_of_int lit
  | Lit_float(flit) -> string_of_float flit
  | Lit_comp(re,im) -> " complex<float>(" ^ string_of_float re ^ "," ^ string_of_float im  ^ ") " (* Not sure how to do this *)
  | Unop(op, expr) ->  writeUnop op expr
  | Binop(expr1, op, expr2) -> writeBinop expr1 op expr2
  | Lit_qub(vec, t) -> writeQubit vec t
  | Mat (expr_wrap) -> writeMatrix expr_wrap
  | Id(str) -> str 
  | Assign(name, expr) ->  name  ^ " = " ^ cppExpr (expr_of expr)
  | Call(str,expr_wrap) ->
          if str = "print" then
               writePrintStmt expr_wrap 
          else
                str ^ "(" ^ writeFunCall expr_wrap ^ ")"    
  | Noexpr -> ""

(* block of statement lists*)  
and cppStmtBlock sstmtl = 
let slist = List.fold_left (fun output element ->
    let stmt = cppStmt  element in
    output ^ stmt ^ "\n") "" sstmtl in
    "\n\t{\n" ^ slist ^ "\t}\n"

(* if statement*)
and writeIfStmt expr stmt1 stmt2 = 
	let cond = cppExpr expr in
    let body = cppStmt stmt1 in
    let ebody = writeElseStmt stmt2 in
    sprintf "if(%s)%s%s" cond body ebody  

(* else statements *)
and writeElseStmt stmt =
    let body =
        cppStmt stmt
    in
        if ((String.compare body ";\n\t") = 0) then
            sprintf "\n"
        else
            sprintf "\telse%s" body


(* while statement*)
and writeWhileStmt expr stmt = 
let condString = cppExpr expr  
  and stmtString = cppStmt stmt in 
    sprintf "while (%s)\n%s\n" condString stmtString

(*for statements*)
and writeForStmt var init final increment stmt =
    let varname = cppExpr (expr_of var) 
    and initvalue = cppExpr (expr_of init)
    and finalvalue = cppExpr (expr_of final)
    and incrementval = cppExpr (expr_of increment)
    and stmtbody = cppStmt stmt
    in
    sprintf "
    for (int %s = %s; %s < %s; %s = %s + %s){
        %s
        }" varname initvalue varname finalvalue varname varname incrementval stmtbody

(* print statement *)
and writePrintStmt expr_wrap =
    let expr = cppExpr (expr_of (List.hd expr_wrap)) 
    and t = type_of (List.hd expr_wrap) in
        let printIt expr t = match t with
                Sast.Qubk ->  sprintf "cout << qubitToString(%s) << endl" expr
               | Sast.Qubb -> sprintf "cout << qubitToString(%s) << endl" expr
               | _ -> sprintf "cout << %s << endl" expr 
        in printIt expr t

(* binary operations *)
and writeBinop expr1 op expr2 = 
    let e1 = cppExpr (expr_of expr1) 
    and t1 = type_of expr1  
    and e2 = cppExpr (expr_of expr2) in 
    	let binopFunc e1 t1 op e2 = match op with 
		 Ast.Add 	-> sprintf "%s + %s" e1 e2
		| Ast.Sub 	-> sprintf "%s - %s" e1 e2
		| Ast.Mult 	-> sprintf "%s * %s" e1 e2
		| Ast.Div 	-> sprintf "%s / %s" e1 e2
		| Ast.Mod 	-> sprintf "%s ! %s" e1 e2
		| Ast.Expn 	-> sprintf "pow(%s,%s)" e1 e2
		| Ast.Tens 	-> sprintf "tensor(%s, %s)" e1 e2
		| Ast.Eq 	-> equalCaseWise e1 t1 e2
		| Ast.Neq 	-> sprintf "%s != %s" e1 e2
		| Ast.Lt 	-> sprintf "%s < %s" e1 e2
		| Ast.Gt 	-> sprintf "%s > %s" e1 e2
		| Ast.Leq 	-> sprintf "%s <= %s" e1 e2
		| Ast.Geq 	-> sprintf "%s >= %s" e1 e2
		| Ast.Or 	-> sprintf "%s || %s" e1 e2
		| Ast.And 	-> sprintf "%s && %s" e1 e2
		| Ast.Xor 	-> sprintf "%s ^ %s" e1 e2
	in binopFunc e1 t1 op e2 

(*equality is structure hence different for different datatypes*)

and equalCaseWise e1 t1 e2 = match t1 with
       Sast.Mati -> sprintf "%s.isApprox(%s)" e1 e2
      |Sast.Matf -> sprintf "%s.isApprox(%s)" e1 e2
      |Sast.Matc -> sprintf "%s.isApprox(%s)" e1 e2
      |Sast.Qubb -> sprintf "%s.isApprox(%s)" e1 e2
      |Sast.Qubk -> sprintf "%s.isApprox(%s)" e1 e2
      | _ -> sprintf "%s == %s" e1 e2        

(*matrices which is list of list of expression wrapper*)
and writeMatrix expr_wrap = 
    let matrixStr = List.fold_left (fun a b -> a ^ (writeRow b)) "" expr_wrap in
    let submatrix = String.sub matrixStr 0 ((String.length matrixStr)-1) in
    sprintf "(Matrix<complex<float>, Dynamic, Dynamic>(%d,%d)<<%s).finished()" (rowMatrix expr_wrap) (colMatrix expr_wrap) submatrix

and writeRow row_expr =
    let rowStr = List.fold_left (fun a b -> a ^ (cppExpr (expr_of b)) ^ "," ) "" row_expr in
    sprintf "%s" rowStr

and colMatrix expr_wrap = List.length (List.hd expr_wrap)

and rowMatrix expr_wrap = List.length expr_wrap

(*function calls variable names *)
and writeFunCall expr_wrap =
    let argvStr = List.fold_left (fun a b -> a ^ (cppExpr (expr_of b)) ^ ",") "" expr_wrap in
    let argvStrCom = String.sub argvStr 0 ((String.length argvStr)-1) in
    sprintf "%s" argvStrCom

(* uniary operators *)
and writeUnop op expr = 
    let exp = cppExpr (expr_of expr) in 
        let unopFunc op exp = match op with
          Ast.Neg   -> sprintf "  -%s" exp
        | Ast.Not   -> sprintf "  !(%s)" exp
        | Ast.Re    -> sprintf "  real(%s)" exp 	(* assumes exp is matrix*)
        | Ast.Im    -> sprintf "  imag(%s)" exp
        | Ast.Norm  -> sprintf "  norm(%s)" exp
        | Ast.Trans -> sprintf "  %s.transpose()" exp
        | Ast.Det   -> sprintf "  %s.determinant()" exp
        | Ast.Adj   -> sprintf "  %s.adjoint()" exp
        | Ast.Conj  -> sprintf "  %s.conjugate()" exp
        | Ast.Unit  -> sprintf "  (%s.conjugate()*%s).isIdentity()" exp exp 		(* till here *)
        | Ast.Sin   -> sprintf "  sin((double)%s)" exp
        | Ast.Cos   -> sprintf "  cos((double)%s)" exp
        | Ast.Tan   -> sprintf "  tan((double)%s)" exp
    in unopFunc op exp

(* generate qubits *)
and writeQubit expr bra=
   (* let exp = string_of_int expr in *)
    sprintf "genQubit(\"%s\",%d)" expr bra
     
(*
(* generating qubits *)
and writeQubit expr =
	sprintf "genQubit(%s)" expr
	*)
