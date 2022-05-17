module Elm.Annotation exposing
    ( Annotation, var, bool, int, float, string, char, unit
    , named, namedWith
    , maybe, list, tuple, triple, set, dict, result
    , record, extensible, alias
    , function
    , toString
    )

{-|

@docs Annotation, var, bool, int, float, string, char, unit

@docs named, namedWith

@docs maybe, list, tuple, triple, set, dict, result

@docs record, extensible, alias

@docs function

@docs toString

-}

import Elm.Syntax.TypeAnnotation as Annotation
import Elm.Writer
import Internal.Compiler as Compiler


{-| -}
type alias Annotation =
    Compiler.Annotation


{-| -}
toString : Annotation -> String
toString (Compiler.Annotation ann) =
    Elm.Writer.writeTypeAnnotation (Compiler.nodify ann.annotation)
        |> Elm.Writer.write


{-| A type variable
-}
var : String -> Annotation
var a =
    Compiler.Annotation
        { annotation = Annotation.GenericType (Compiler.formatValue a)
        , imports = []
        , aliases = Compiler.emptyAliases
        }


{-| -}
bool : Annotation
bool =
    typed [] "Bool" []


{-| -}
int : Annotation
int =
    typed [] "Int" []


{-| -}
float : Annotation
float =
    typed [] "Float" []


{-| -}
string : Annotation
string =
    typed [] "String" []


{-| -}
char : Annotation
char =
    typed [ "Char" ] "Char" []


{-| -}
unit : Annotation
unit =
    Compiler.Annotation
        { annotation = Annotation.Unit
        , imports = []
        , aliases = Compiler.emptyAliases
        }


{-| -}
list : Annotation -> Annotation
list inner =
    typed [] "List" [ inner ]


{-| -}
result : Annotation -> Annotation -> Annotation
result err ok =
    typed [] "Result" [ err, ok ]


{-| -}
tuple : Annotation -> Annotation -> Annotation
tuple one two =
    Compiler.Annotation
        { annotation =
            Annotation.Tupled
                (Compiler.nodifyAll
                    [ Compiler.getInnerAnnotation one
                    , Compiler.getInnerAnnotation two
                    ]
                )
        , imports =
            Compiler.getAnnotationImports one
                ++ Compiler.getAnnotationImports two
        , aliases =
            Compiler.mergeAliases (getAliases one) (getAliases two)
        }


getAliases : Annotation -> Compiler.AliasCache
getAliases (Compiler.Annotation ann) =
    ann.aliases


{-| -}
triple : Annotation -> Annotation -> Annotation -> Annotation
triple one two three =
    Compiler.Annotation
        { annotation =
            Annotation.Tupled
                (Compiler.nodifyAll
                    [ Compiler.getInnerAnnotation one
                    , Compiler.getInnerAnnotation two
                    , Compiler.getInnerAnnotation three
                    ]
                )
        , imports =
            Compiler.getAnnotationImports one
                ++ Compiler.getAnnotationImports two
                ++ Compiler.getAnnotationImports three
        , aliases =
            Compiler.mergeAliases
                (Compiler.mergeAliases
                    (getAliases one)
                    (getAliases two)
                )
                (getAliases three)
        }


{-| -}
set : Annotation -> Annotation
set setArg =
    typed [ "Set" ] "Set" [ setArg ]


{-| -}
dict : Annotation -> Annotation -> Annotation
dict keyArg valArg =
    typed [ "Dict" ] "Dict" [ keyArg, valArg ]


{-| -}
maybe : Annotation -> Annotation
maybe maybeArg =
    typed [] "Maybe" [ maybeArg ]


{-| -}
alias :
    List String
    -> String
    -> List Annotation
    -> Annotation
    -> Annotation
alias mod name vars target =
    Compiler.Annotation
        { annotation =
            Annotation.Typed
                (Compiler.nodify
                    ( mod, Compiler.formatType name )
                )
                (List.map (Compiler.nodify << Compiler.getInnerAnnotation) vars)
        , imports =
            case mod of
                [] ->
                    Compiler.getAnnotationImports target
                        ++ List.concatMap Compiler.getAnnotationImports vars

                _ ->
                    [ mod ]
                        ++ Compiler.getAnnotationImports target
                        ++ List.concatMap Compiler.getAnnotationImports vars
        , aliases =
            List.foldl
                (\ann aliases ->
                    Compiler.mergeAliases (Compiler.getAliases ann) aliases
                )
                (Compiler.getAliases target)
                vars
                |> Compiler.addAlias mod name target
        }


{-| -}
record : List ( String, Annotation ) -> Annotation
record fields =
    Compiler.Annotation
        { annotation =
            fields
                |> List.map
                    (\( name, ann ) ->
                        ( Compiler.nodify (Compiler.formatValue name)
                        , Compiler.nodify (Compiler.getInnerAnnotation ann)
                        )
                    )
                |> Compiler.nodifyAll
                |> Annotation.Record
        , imports =
            fields
                |> List.concatMap (Tuple.second >> Compiler.getAnnotationImports)
        , aliases =
            List.foldl
                (\( _, ann ) aliases ->
                    Compiler.mergeAliases (getAliases ann) aliases
                )
                Compiler.emptyAliases
                fields
        }


{-| -}
extensible : String -> List ( String, Annotation ) -> Annotation
extensible base fields =
    Compiler.Annotation
        { annotation =
            fields
                |> List.map
                    (\( name, ann ) ->
                        ( Compiler.nodify name
                        , Compiler.nodify (Compiler.getInnerAnnotation ann)
                        )
                    )
                |> Compiler.nodifyAll
                |> Compiler.nodify
                |> Annotation.GenericRecord (Compiler.nodify (Compiler.formatValue base))
        , imports =
            fields
                |> List.concatMap (Tuple.second >> Compiler.getAnnotationImports)
        , aliases =
            List.foldl
                (\( _, ann ) aliases ->
                    Compiler.mergeAliases (getAliases ann) aliases
                )
                Compiler.emptyAliases
                fields
        }


{-| -}
named : List String -> String -> Annotation
named mod name =
    Compiler.Annotation
        { annotation =
            Annotation.Typed
                (Compiler.nodify
                    ( mod, Compiler.formatType name )
                )
                []
        , imports =
            case mod of
                [] ->
                    []

                _ ->
                    [ mod ]
        , aliases = Compiler.emptyAliases
        }


{-| -}
namedWith : List String -> String -> List Annotation -> Annotation
namedWith mod name args =
    Compiler.Annotation
        { annotation =
            Annotation.Typed
                (Compiler.nodify
                    ( mod
                    , Compiler.formatType name
                    )
                )
                (Compiler.nodifyAll
                    (List.map Compiler.getInnerAnnotation
                        args
                    )
                )
        , imports =
            mod
                :: List.concatMap Compiler.getAnnotationImports
                    args
        , aliases =
            List.foldl
                (\ann aliases ->
                    Compiler.mergeAliases (getAliases ann) aliases
                )
                Compiler.emptyAliases
                args
        }


{-| -}
typed : List String -> String -> List Annotation -> Annotation
typed mod name args =
    Compiler.Annotation
        { annotation =
            Annotation.Typed
                (Compiler.nodify ( mod, name ))
                (Compiler.nodifyAll
                    (List.map Compiler.getInnerAnnotation args)
                )
        , imports = List.concatMap Compiler.getAnnotationImports args
        , aliases =
            List.foldl
                (\ann aliases ->
                    Compiler.mergeAliases (getAliases ann) aliases
                )
                Compiler.emptyAliases
                args
        }


{-| -}
function : List Annotation -> Annotation -> Annotation
function anns return =
    Compiler.Annotation
        { annotation =
            List.foldr
                (\ann fn ->
                    Annotation.FunctionTypeAnnotation
                        (Compiler.nodify ann)
                        (Compiler.nodify fn)
                )
                (Compiler.getInnerAnnotation return)
                (List.map Compiler.getInnerAnnotation anns)
        , imports =
            Compiler.getAnnotationImports return
                ++ List.concatMap Compiler.getAnnotationImports anns
        , aliases =
            List.foldl
                (\ann aliases ->
                    Compiler.mergeAliases (getAliases ann) aliases
                )
                Compiler.emptyAliases
                (return :: anns)
        }
