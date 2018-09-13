open Printf

module List    = ListLabels

module Map    = Tiger_map
module Symbol = Tiger_symbol

type unique =
  unit ref

type t =
  | Unit
  | Nil
  | Int
  | String
  | Record of
      { unique : unique
      ; fields : (Symbol.t * t) list
      }
  | Array of
      { unique : unique
      ; ty     : t
      }
  | Name of Symbol.t * t option ref

type env =
  (Symbol.t, t ) Map.t

let new_unique () =
  ref ()

let new_record fields =
  Record
    { fields
    ; unique = new_unique ()
    }

let new_array ty =
  Array
    { ty
    ; unique = new_unique ()
    }

let is_equal t1 t2 =
  match t1, t2 with
  | Record {unique=u1; _},  Record {unique=u2; _} -> u1 == u2
  | Array  {unique=u1; _},  Array  {unique=u2; _} -> u1 == u2
  | t1                   , t2                     -> t1 =  t2
  (* The above pattern matching is "fragile" and I'm OK with it.
   * TODO: Can we ignore the warning locally?
   * *)

let is_record = function
  | Unit
  | Int
  | String
  | Name _
  | Array  _ -> false
  | Nil  (* nil belongs to ANY record *)
  | Record _ -> true

let is_int = function
  | Unit
  | Nil
  | String
  | Name _
  | Record _
  | Array  _ -> false
  | Int      -> true

let is_name = function
  | Unit
  | Nil
  | String
  | Int
  | Record _
  | Array  _ -> false
  | Name _   -> true

let to_string = function
  | Unit               -> "unit"
  | Nil                -> "nil"
  | String             -> "string"
  | Record {unique; _} -> sprintf "record(%d)" (Obj.magic unique)
  | Array  {unique; _} -> sprintf "array(%d)"  (Obj.magic unique)
  | Int                -> "int"
  | Name (name, _)     -> Symbol.to_string name

let built_in =
  [ ("unit"   , Unit)
  ; ("nil"    , Nil)
  ; ("int"    , Int)
  ; ("string" , String)
  ]
  |> List.map ~f:(fun (k, v) -> (Symbol.of_string k, v))
  |> Map.of_list