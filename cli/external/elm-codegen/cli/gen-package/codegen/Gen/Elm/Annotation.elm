module Gen.Elm.Annotation exposing (alias, annotation_, bool, call_, char, dict, extensible, float, function, int, list, maybe, moduleName_, named, namedWith, record, result, set, string, toString, triple, tuple, unit, values_, var)

{-| 
@docs moduleName_, var, bool, int, float, string, char, unit, named, namedWith, maybe, list, tuple, triple, set, dict, result, record, extensible, alias, function, toString, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Elm", "Annotation" ]


{-| A type variable

var: String -> Elm.Annotation.Annotation
-}
var : String -> Elm.Expression
var arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "var"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.string arg ]


{-| bool: Elm.Annotation.Annotation -}
bool : Elm.Expression
bool =
    Elm.value
        { importFrom = [ "Elm", "Annotation" ]
        , name = "bool"
        , annotation =
            Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
        }


{-| int: Elm.Annotation.Annotation -}
int : Elm.Expression
int =
    Elm.value
        { importFrom = [ "Elm", "Annotation" ]
        , name = "int"
        , annotation =
            Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
        }


{-| float: Elm.Annotation.Annotation -}
float : Elm.Expression
float =
    Elm.value
        { importFrom = [ "Elm", "Annotation" ]
        , name = "float"
        , annotation =
            Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
        }


{-| string: Elm.Annotation.Annotation -}
string : Elm.Expression
string =
    Elm.value
        { importFrom = [ "Elm", "Annotation" ]
        , name = "string"
        , annotation =
            Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
        }


{-| char: Elm.Annotation.Annotation -}
char : Elm.Expression
char =
    Elm.value
        { importFrom = [ "Elm", "Annotation" ]
        , name = "char"
        , annotation =
            Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
        }


{-| unit: Elm.Annotation.Annotation -}
unit : Elm.Expression
unit =
    Elm.value
        { importFrom = [ "Elm", "Annotation" ]
        , name = "unit"
        , annotation =
            Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
        }


{-| named: List String -> String -> Elm.Annotation.Annotation -}
named : List String -> String -> Elm.Expression
named arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "named"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string, Type.string ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg), Elm.string arg0 ]


{-| namedWith: 
    List String
    -> String
    -> List Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
namedWith : List String -> String -> List Elm.Expression -> Elm.Expression
namedWith arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "namedWith"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.list
                            (Type.namedWith
                                [ "Elm", "Annotation" ]
                                "Annotation"
                                []
                            )
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg), Elm.string arg0, Elm.list arg1 ]


{-| maybe: Elm.Annotation.Annotation -> Elm.Annotation.Annotation -}
maybe : Elm.Expression -> Elm.Expression
maybe arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "maybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg ]


{-| list: Elm.Annotation.Annotation -> Elm.Annotation.Annotation -}
list : Elm.Expression -> Elm.Expression
list arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "list"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg ]


{-| tuple: 
    Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
tuple : Elm.Expression -> Elm.Expression -> Elm.Expression
tuple arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "tuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg, arg0 ]


{-| triple: 
    Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
triple : Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
triple arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "triple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg, arg0, arg1 ]


{-| set: Elm.Annotation.Annotation -> Elm.Annotation.Annotation -}
set : Elm.Expression -> Elm.Expression
set arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "set"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg ]


{-| dict: 
    Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
dict : Elm.Expression -> Elm.Expression -> Elm.Expression
dict arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "dict"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg, arg0 ]


{-| result: 
    Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
result : Elm.Expression -> Elm.Expression -> Elm.Expression
result arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "result"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ arg, arg0 ]


{-| record: List ( String, Elm.Annotation.Annotation ) -> Elm.Annotation.Annotation -}
record : List Elm.Expression -> Elm.Expression
record arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "record"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.tuple
                                Type.string
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.list arg ]


{-| extensible: 
    String
    -> List ( String, Elm.Annotation.Annotation )
    -> Elm.Annotation.Annotation
-}
extensible : String -> List Elm.Expression -> Elm.Expression
extensible arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "extensible"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.list
                            (Type.tuple
                                Type.string
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.string arg, Elm.list arg0 ]


{-| alias: 
    List String
    -> String
    -> List Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
alias :
    List String
    -> String
    -> List Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
alias arg arg0 arg1 arg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "alias"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.list
                            (Type.namedWith
                                [ "Elm", "Annotation" ]
                                "Annotation"
                                []
                            )
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.list arg1
        , arg2
        ]


{-| function: 
    List Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
    -> Elm.Annotation.Annotation
-}
function : List Elm.Expression -> Elm.Expression -> Elm.Expression
function arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "function"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Elm", "Annotation" ]
                                "Annotation"
                                []
                            )
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ Elm.list arg, arg0 ]


{-| toString: Elm.Annotation.Annotation -> String -}
toString : Elm.Expression -> Elm.Expression
toString arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        Type.string
                    )
            }
        )
        [ arg ]


annotation_ : { annotation : Type.Annotation }
annotation_ =
    { annotation =
        Type.alias
            moduleName_
            "Annotation"
            []
            (Type.namedWith [ "Internal", "Compiler" ] "Annotation" [])
    }


call_ :
    { var : Elm.Expression -> Elm.Expression
    , named : Elm.Expression -> Elm.Expression -> Elm.Expression
    , namedWith :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , maybe : Elm.Expression -> Elm.Expression
    , list : Elm.Expression -> Elm.Expression
    , tuple : Elm.Expression -> Elm.Expression -> Elm.Expression
    , triple :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , set : Elm.Expression -> Elm.Expression
    , dict : Elm.Expression -> Elm.Expression -> Elm.Expression
    , result : Elm.Expression -> Elm.Expression -> Elm.Expression
    , record : Elm.Expression -> Elm.Expression
    , extensible : Elm.Expression -> Elm.Expression -> Elm.Expression
    , alias :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , function : Elm.Expression -> Elm.Expression -> Elm.Expression
    , toString : Elm.Expression -> Elm.Expression
    }
call_ =
    { var =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "var"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg ]
    , named =
        \arg arg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "named"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string, Type.string ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg1 ]
    , namedWith =
        \arg arg2 arg3 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "namedWith"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.list
                                    (Type.namedWith
                                        [ "Elm", "Annotation" ]
                                        "Annotation"
                                        []
                                    )
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg2, arg3 ]
    , maybe =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "maybe"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg ]
    , list =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "list"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg ]
    , tuple =
        \arg arg5 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "tuple"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg5 ]
    , triple =
        \arg arg6 arg7 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "triple"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg6, arg7 ]
    , set =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "set"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg ]
    , dict =
        \arg arg8 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "dict"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg8 ]
    , result =
        \arg arg9 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "result"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg9 ]
    , record =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "record"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.tuple
                                        Type.string
                                        (Type.namedWith
                                            [ "Elm", "Annotation" ]
                                            "Annotation"
                                            []
                                        )
                                    )
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg ]
    , extensible =
        \arg arg11 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "extensible"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string
                                , Type.list
                                    (Type.tuple
                                        Type.string
                                        (Type.namedWith
                                            [ "Elm", "Annotation" ]
                                            "Annotation"
                                            []
                                        )
                                    )
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg11 ]
    , alias =
        \arg arg12 arg13 arg14 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "alias"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.list
                                    (Type.namedWith
                                        [ "Elm", "Annotation" ]
                                        "Annotation"
                                        []
                                    )
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg12, arg13, arg14 ]
    , function =
        \arg arg13 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "function"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list
                                    (Type.namedWith
                                        [ "Elm", "Annotation" ]
                                        "Annotation"
                                        []
                                    )
                                , Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                    }
                )
                [ arg, arg13 ]
    , toString =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Annotation" ]
                    , name = "toString"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                ]
                                Type.string
                            )
                    }
                )
                [ arg ]
    }


values_ :
    { var : Elm.Expression
    , bool : Elm.Expression
    , int : Elm.Expression
    , float : Elm.Expression
    , string : Elm.Expression
    , char : Elm.Expression
    , unit : Elm.Expression
    , named : Elm.Expression
    , namedWith : Elm.Expression
    , maybe : Elm.Expression
    , list : Elm.Expression
    , tuple : Elm.Expression
    , triple : Elm.Expression
    , set : Elm.Expression
    , dict : Elm.Expression
    , result : Elm.Expression
    , record : Elm.Expression
    , extensible : Elm.Expression
    , alias : Elm.Expression
    , function : Elm.Expression
    , toString : Elm.Expression
    }
values_ =
    { var =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "var"
            , annotation =
                Just
                    (Type.function
                        [ Type.string ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , bool =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "bool"
            , annotation =
                Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
            }
    , int =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "int"
            , annotation =
                Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
            }
    , float =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "float"
            , annotation =
                Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
            }
    , string =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "string"
            , annotation =
                Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
            }
    , char =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "char"
            , annotation =
                Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
            }
    , unit =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "unit"
            , annotation =
                Just (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
            }
    , named =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "named"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string, Type.string ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , namedWith =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "namedWith"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.list
                            (Type.namedWith
                                [ "Elm", "Annotation" ]
                                "Annotation"
                                []
                            )
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , maybe =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "maybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , list =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "list"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , tuple =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "tuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , triple =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "triple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , set =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "set"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , dict =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "dict"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , result =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "result"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , record =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "record"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.tuple
                                Type.string
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , extensible =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "extensible"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.list
                            (Type.tuple
                                Type.string
                                (Type.namedWith
                                    [ "Elm", "Annotation" ]
                                    "Annotation"
                                    []
                                )
                            )
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , alias =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "alias"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.list
                            (Type.namedWith
                                [ "Elm", "Annotation" ]
                                "Annotation"
                                []
                            )
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , function =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "function"
            , annotation =
                Just
                    (Type.function
                        [ Type.list
                            (Type.namedWith
                                [ "Elm", "Annotation" ]
                                "Annotation"
                                []
                            )
                        , Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        (Type.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
    , toString =
        Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "toString"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm", "Annotation" ] "Annotation" []
                        ]
                        Type.string
                    )
            }
    }


