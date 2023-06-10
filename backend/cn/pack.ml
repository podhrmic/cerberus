open IndexTerms
open BaseTypes
open ResourceTypes
open Resources
open ResourcePredicates
open Memory
module IT = IndexTerms
module LAT = LogicalArgumentTypes


let resource_empty provable resource = 
  let constr = match resource with
    | (P p, _) -> LC.t_ (not_ p.permission)
    | (Q p, _) -> LC.forall_ (p.q, BT.Integer) (not_ p.permission)
  in
  match provable constr with
  | `True -> `Empty
  | `False -> `NonEmpty (constr, Solver.model ())



let packing_ft loc global provable ret = 
  match ret with
  | P ret ->
     begin match ret.name with
      | Owned ((Void | Integer _ | Pointer _ | Function _), _init) -> 
         None
      | Owned ((Array (ict, olength)) as ct, init) ->
         let length = Option.get olength in
         let qpred = 
           let q_s, q = IT.fresh_named Integer "i" in
           Q { 
             name = Owned (ict, init);
             pointer = ret.pointer;
             q = q_s;
             step = int_ (Memory.size_of_ctype ict);
             iargs = [];
             permission = and_ [ret.permission; ((int_ 0) %<= q); (q %< (int_ length))]
           }
         in
         let o_s, o = IT.fresh_named (BT.of_sct ct) "value" in
         let at = 
           LAT.Resource ((o_s, (qpred, IT.bt o)), (loc, None),
           LAT.I o)
         in
         Some at
      | Owned (Struct tag, init) ->
          let layout = SymMap.find tag global.Global.struct_decls in
          let lrt, value =
            List.fold_right (fun {offset; size; member_or_padding} (lrt, value) ->
              match member_or_padding with
              | Some (member, mct) ->
                let request = 
                  P {
                    name = Owned (mct, init);
                    pointer = memberShift_ (ret.pointer, tag, member);
                    iargs = [];
                    permission = ret.permission;
                  }
                in
                let m_value_s, m_value = IT.fresh_named (BT.of_sct mct) (Id.s member) in
                (LRT.Resource ((m_value_s, (request, IT.bt m_value)), (loc, None), lrt),
                (member, m_value) :: value)
              | None ->
                let padding_ct = Sctypes.Array (Integer Char, Some size) in
                let request = 
                  P {
                    name = Owned (padding_ct, Uninit);
                    pointer = pointer_offset_ (ret.pointer, int_ offset);
                    iargs = [];
                    permission = ret.permission;
                  }
                in
                let padding_s, padding = IT.fresh_named (BT.of_sct padding_ct) "padding" in
                (LRT.Resource ((padding_s, (request, IT.bt padding)), (loc, None), lrt),
                value)
              ) layout (LRT.I, [])
          in
          let at = LAT.of_lrt lrt (LAT.I (struct_ (tag, value))) in
          Some at
      | PName pn -> 
          let def = SymMap.find pn global.resource_predicates in
          begin match identify_right_clause provable def ret.pointer ret.iargs with
          | None -> None
          | Some right_clause -> Some right_clause.packing_ft
          end          
      end
  | Q _ -> 
     None


let unpack loc global provable (ret, O o) = 
  match packing_ft loc global provable ret with
  | None -> None
  | Some packing_ft -> Some (ResourcePredicates.clause_lrt o packing_ft)
      






  let extractable_one loc provable (predicate_name, index) (ret, O o) = 
    match ret with
    | Q ret when equal_predicate_name predicate_name ret.name ->
       let su = IT.make_subst [(ret.q, index)] in
       let index_permission = IT.subst su ret.permission in
       let at_index = 
         (P { name = ret.name;
              pointer = pointer_offset_ (ret.pointer, mul_ (ret.step, index));
              iargs = List.map (IT.subst su) ret.iargs;
              permission = index_permission },
          O (map_get_ o index))
       in
       let ret_reduced = 
         { ret with permission = and_ [ret.permission; ne__ (sym_ (ret.q, Integer)) index ] }
       in
       begin match provable (LC.t_ index_permission) with
       | `True -> Some ((Q ret_reduced, O o), at_index)
       | `False -> None
       end
    | _ -> 
      None


let extractable_multiple loc provable =
  let rec aux is (re, extracted) =
    match is with
    | [] -> 
        (re, extracted)
    | i::is -> 
        match extractable_one loc provable i re with
        | Some (re_reduced, extracted') ->
            aux is (re_reduced, extracted' :: extracted)
        | None ->
            aux is (re, extracted)
  in
  fun movable_indices re -> aux movable_indices (re, [])


