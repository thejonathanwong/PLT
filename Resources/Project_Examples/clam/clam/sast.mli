(*
 * File: sast.ml
 * Date: 2011-10-16
 *
 * PLT Fall 2011
 * CLAM Project
 * Jeremy C. Andrus <jeremya@cs.columbia.edu>
 * Robert Martin <rdm2128@columbia.edu>
 * Kevin Sun <kfs2110@columbia.edu> * Yongxu Zhang <yz2419@columbia.edu>
 *)

(* Identifiers *)
type calcId = string
type kernId = string
type imgId = string
type chanRefId = imgId * calcId
type convData = kernId * chanRefId * Envtypes.calcT list * int
type filenameId = Const of string | Arg of int

(* Environment Objects *)
type sMatrix = (int * int ) * (int * int) * int list list
type fmtType = Png | Bmp | Tga
type typeT = CalcType of Ast.atom
           | KernelType
           | ImageType
           | ChanRefType
           | FilenameType
           | FormatType
           | VoidType
type identT = {
  id: string;
  typ: typeT;
  init: bool;
  chans: string list; (* Only relevant for image identifiers *)
}

type scopeT = {
  venv: Envtypes.envT;
  mutable mats: sMatrix list;
  mutable max_arg: int;
  mutable cvdata : convData list;
}


(* Assignment to a Calc *)
type calcAssign = { c_lhs: calcId; c_rhs: calcEx; c_typ: Ast.atom; }
and calcEx =
    CMatrix of sMatrix
  | CRaw of string * calcId list
  | CChain of calcAssign
  | CIdent of calcId * Ast.atom

(* Assignment to a Kernel *)
type kernAppend = { ka_lhs: kernId; ka_rhs: calcEx; }
type kernAssign = { k_lhs: kernId; k_rhs: kernEx; }
and kernEx =
    KCalcList of calcId list * calcId list * string (* all, unused, assignTo *)
  | KChain of kernAssign
  | KAppend of kernAppend
  | KIdent of kernId

(* Assignment to an Image *)
type imgAppend = { ia_lhs: imgId; ia_rhs: calcEx; }
type imgAssign = { i_lhs: imgId; i_rhs: imgEx; }
and imgEx =
    ImConv of convData
  | ImRead of filenameId
  | ImChain of imgAssign
  | ImAppend of imgAppend
  | ImIdent of imgId

(* Assignment to a Channel Reference *)
type chanAssign = { ch_lhs: chanRefId; ch_rhs: chanRefEx; }
and chanRefEx =
    ChanChain of chanAssign
  | ChanIdent of chanRefId

(* Output images *)
type imgWrite = { im: imgEx; fil: filenameId; fmtType: fmtType; }

type vExpr =
    CalcEx of calcEx
  | KernelEx of kernEx
  | ImageEx of imgEx
  | ChanRefEx of chanRefEx
  | ImgWriteEx of imgEx * fmtType * filenameId
  | Debug of string

type vastRoot = vExpr list
