open Locations
module BT = BaseTypes
module IT = IndexTerms
module LS = LogicalSorts
module RET = ResourceTypes
module LC = LogicalConstraints
module SymSet = Set.Make(Sym)


type 'i t = 
  | Define of (Sym.t * IT.t) * info * 'i t
  | Resource of (Sym.t * (RET.t * BT.t)) * info * 'i t
  | Constraint of LC.t * info * 'i t
  | I of 'i

let mDefine (name, it, info) t = Define ((name, it), info, t)
let mResource (bound, info) t = Resource (bound, info, t)
let mConstraint (bound, info) t = Constraint (bound, info, t)

let mDefines t = List.fold_right mDefine t
let mResources t  = List.fold_right mResource t
let mConstraints t  = List.fold_right mConstraint t



let rec subst i_subst =
  let rec aux (substitution: IT.t Subst.t) at =
    match at with
    | Define ((name, it), info, t) ->
       let it = IT.subst substitution it in
       let name, t = suitably_alpha_rename i_subst substitution.relevant (name, IT.bt it) t in
       Define ((name, it), info, aux substitution t)
    | Resource ((name, (re, bt)), info, t) -> 
       let re = RET.subst substitution re in
       let name, t = suitably_alpha_rename i_subst substitution.relevant (name, bt) t in
       let t = aux substitution t in
       Resource ((name, (re, bt)), info, t)
    | Constraint (lc, info, t) -> 
       let lc = LC.subst substitution lc in
       let t = aux substitution t in
       Constraint (lc, info, t)
    | I i -> 
       let i = i_subst substitution i in
       I i
  in
  aux

and alpha_rename i_subst (s, ls) t = 
  let s' = Sym.fresh_same s in
  (s', subst i_subst (IT.make_subst [(s, IT.sym_ (s', ls))]) t)

and suitably_alpha_rename i_subst syms (s, ls) t = 
  if SymSet.mem s syms 
  then alpha_rename i_subst (s, ls) t
  else (s, t)



open Pp

let rec pp_aux i_pp = function
  | Define ((name, it), _info, t) ->
     group (!^"let" ^^^ (Sym.pp name) ^^^ equals ^^^ IT.pp it ^^ semi) :: pp_aux i_pp t
  | Resource ((name, (re, _bt)), _info, t) ->
     group (!^"let" ^^^ (Sym.pp name) ^^^ equals ^^^ RET.pp re ^^ semi) :: pp_aux i_pp t
  | Constraint (lc, _info, t) ->
     let op = equals ^^ rangle in
     group (LC.pp lc ^^^ op) :: pp_aux i_pp t
  | I i -> 
     [i_pp i]


let pp i_pp ft = 
  flow (break 1) (pp_aux i_pp ft)


let rec get_return = function
  | Define (_, _, ft) -> get_return ft
  | Resource (_, _, ft) -> get_return ft
  | Constraint (_, _, ft) -> get_return ft
  | I rt -> rt


module LRT = LogicalReturnTypes
module RT = ReturnTypes


let alpha_unique ss =
  let rename_if ss = suitably_alpha_rename RT.subst ss in
  let rec f ss at =
    match at with
    | Define ((name, it), info, t) ->
       let name, t = rename_if ss (name, IT.bt it) t in
       let t = f (SymSet.add name ss) t in
       Define ((name, it), info, t)
    | Resource ((name, (re, bt)), info, t) ->
       let name, t = rename_if ss (name, bt) t in
       let t = f (SymSet.add name ss) t in
       Resource ((name, (re, bt)), info, f ss t)
    | Constraint (lc, info, t) -> Constraint (lc, info, f ss t)
    | I i -> I (RT.alpha_unique ss i)
  in
  f ss


let rec of_lrt (lrt : LRT.t) (rest : 'i t) : 'i t = 
  match lrt with
  | LRT.I -> 
     rest
  | LRT.Define ((name, it), info, args) ->
     Define ((name, it), info, of_lrt args rest)
  | LRT.Resource ((name, t), info, args) -> 
     Resource ((name, t), info, of_lrt args rest)
  | LRT.Constraint (t, info, args) -> 
     Constraint (t, info, of_lrt args rest)

let rec map (f : 'i -> 'j) (at : 'i t) : 'j t =
  match at with
  | Define (bound, info, at) ->
     Define (bound, info, map f at)
  | Resource (bound, info, at) -> 
     Resource (bound, info, map f at)
  | Constraint (lc, info, at) -> 
     Constraint (lc, info, map f at)
  | I i ->
     I (f i)



let rec r_resource_requests r =
  match r with
  | Define (_, _, t) ->
     r_resource_requests t
  | Resource (resource, info, t) -> 
     resource :: r_resource_requests t
  | Constraint (_, _, t) ->
     r_resource_requests t
  | I _ -> 
     []


let rec logical_arguments_and_return (at : 'i t) : LRT.t * 'i =
  match at with
  | I r ->
     (LRT.I, r)
  | Define ((name, it), info, args) ->
     let (lrt, r) = logical_arguments_and_return args in
     (LRT.Define ((name, it), info, lrt), r)
  | Resource ((name, t), info, args) ->
     let (lrt, r) = logical_arguments_and_return args in
     (LRT.Resource ((name, t), info, lrt), r)
  | Constraint (t, info, args) ->
     let (lrt, r) = logical_arguments_and_return args in
     (LRT.Constraint (t, info, lrt), r)



type packing_ft = OutputDef.t t
type lft = LogicalReturnTypes.t t