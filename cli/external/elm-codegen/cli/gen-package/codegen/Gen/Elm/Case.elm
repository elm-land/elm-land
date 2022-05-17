module Gen.Elm.Case exposing (annotation_, branch0, branch1, branch2, branch3, branch4, branch5, branch6, branchWith, call_, custom, list, listBranch, maybe, moduleName_, otherwise, result, triple, tuple, values_)

{-| 
@docs moduleName_, maybe, result, list, tuple, triple, custom, otherwise, branch0, branch1, branch2, branch3, branch4, branch5, branch6, branchWith, listBranch, annotation_, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Elm", "Case" ]


{-| Elm.fn "myMaybe" <|
        \myMaybe ->
            Elm.Case.maybe myMaybe
                { nothing = Elm.int 0
                , just =
                    \content ->
                        Elm.plus (Elm.int 5) content
                }

Generates

    \myMaybe ->
        case myMaybe of
            Nothing ->
                0

            Just just ->
                just + 5

maybe: 
    Elm.Expression
    -> { nothing : Elm.Expression, just : Elm.Expression -> Elm.Expression }
    -> Elm.Expression
-}
maybe :
    Elm.Expression
    -> { nothing : Elm.Expression, just : Elm.Expression -> Elm.Expression }
    -> Elm.Expression
maybe arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "maybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.record
                            [ ( "nothing"
                              , Type.namedWith [ "Elm" ] "Expression" []
                              )
                            , ( "just"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg
        , Elm.record
            [ Elm.field "nothing" arg0.nothing
            , Elm.field "just" (Elm.functionReduced "unpack" arg0.just)
            ]
        ]


{-| Elm.fn "myResult" <|
        \myResult ->
            Elm.Case.triple myResult
                { ok =
                    \ok ->
                        Elm.string "No errors"
                , err =
                    \err ->
                        err
                }

Generates

    \myResult ->
        case myResult of
            Ok ok ->
                "No errors"

            Err err ->
                err

result: 
    Elm.Expression
    -> { err : Elm.Expression -> Elm.Expression
    , ok : Elm.Expression -> Elm.Expression
    }
    -> Elm.Expression
-}
result :
    Elm.Expression
    -> { err : Elm.Expression -> Elm.Expression
    , ok : Elm.Expression -> Elm.Expression
    }
    -> Elm.Expression
result arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "result"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.record
                            [ ( "err"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            , ( "ok"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg
        , Elm.record
            [ Elm.field "err" (Elm.functionReduced "unpack" arg0.err)
            , Elm.field "ok" (Elm.functionReduced "unpack" arg0.ok)
            ]
        ]


{-| Elm.fn "myList" <|
        \myList ->
            Elm.Case.list myList
                { empty = Elm.int 0
                , nonEmpty =
                    \top remaining ->
                        Elm.plus (Elm.int 5) top
                }

Generates

    \myList ->
        case myList of
            [] ->
                0

            top :: remaining ->
                top + 5

list: 
    Elm.Expression
    -> { empty : Elm.Expression
    , nonEmpty : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
    -> Elm.Expression
-}
list :
    Elm.Expression
    -> { empty : Elm.Expression
    , nonEmpty : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
    -> Elm.Expression
list arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "list"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.record
                            [ ( "empty"
                              , Type.namedWith [ "Elm" ] "Expression" []
                              )
                            , ( "nonEmpty"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg
        , Elm.record
            [ Elm.field "empty" arg0.empty
            , Elm.field
                "nonEmpty"
                (Elm.functionReduced
                    "unpack"
                    (\unpack ->
                        Elm.functionReduced "unpack" (arg0.nonEmpty unpack)
                    )
                )
            ]
        ]


{-| Elm.fn "myTuple" <|
        \myTuple ->
            Elm.Case.tuple myTuple
                { nothing = Elm.int 0
                , just =
                    \one two ->
                        Elm.plus (Elm.int 5) two
                }

Generates

    \myTuple ->
        case myTuple of
            ( one, two ) ->
                5 + two

tuple: 
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
-}
tuple :
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
tuple arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "tuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg
        , Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg0 unpack))
        ]


{-| Elm.fn "myTriple" <|
        \myTriple ->
            Elm.Case.triple myTriple
                { nothing = Elm.int 0
                , just =
                    \one two three ->
                        Elm.plus (Elm.int 5) two
                }

Generates

    \myTriple ->
        case myTriple of
            ( one, two, three ) ->
                5 + two

triple: 
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
-}
triple :
    Elm.Expression
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
triple arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "triple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg
        , Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced "unpack" (arg0 unpack unpack0)
                    )
            )
        ]


{-| Elm.fn "maybeString" <|
        \maybeString ->
            Elm.Case.custom maybeString
                [ Elm.Case.branch [ "Maybe" ]
                    "Nothing"
                    (Elm.string "It's nothing, I swear!")
                , Elm.Case.branch2 [ "Maybe" ] "Just" <|
                    \just ->
                        Elm.append (Elm.string "Actually, it's: ") just
                ]

Generates

    \maybeString ->
        case maybeString of
            Nothing ->
                "It's nothing, I swear!"

            Just just ->
                "Actually, it's " ++ just

custom: Elm.Expression -> List Elm.Case.Branch -> Elm.Expression
-}
custom : Elm.Expression -> List Elm.Expression -> Elm.Expression
custom arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "custom"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.list
                            (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg, Elm.list arg0 ]


{-| A catchall branch in case you want the case to be nonexhaustive.

otherwise: (Elm.Expression -> Elm.Expression) -> Elm.Case.Branch
-}
otherwise : (Elm.Expression -> Elm.Expression) -> Elm.Expression
otherwise arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "otherwise"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" [] ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg ]


{-| branch0: List String -> String -> Elm.Expression -> Elm.Case.Branch -}
branch0 : List String -> String -> Elm.Expression -> Elm.Expression
branch0 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch0"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg), Elm.string arg0, arg1 ]


{-| branch1: List String -> String -> (Elm.Expression -> Elm.Expression) -> Elm.Case.Branch -}
branch1 :
    List String
    -> String
    -> (Elm.Expression -> Elm.Expression)
    -> Elm.Expression
branch1 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch1"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" [] ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.functionReduced "unpack" arg1
        ]


{-| branch2: 
    List String
    -> String
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Case.Branch
-}
branch2 :
    List String
    -> String
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
branch2 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch2"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg1 unpack))
        ]


{-| branch3: 
    List String
    -> String
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Case.Branch
-}
branch3 :
    List String
    -> String
    -> (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
branch3 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch3"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced "unpack" (arg1 unpack unpack0)
                    )
            )
        ]


{-| branch4: 
    List String
    -> String
    -> (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Case.Branch
-}
branch4 :
    List String
    -> String
    -> (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
branch4 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch4"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_5_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (arg1 unpack unpack0 unpack_4_3_5_3_0)
                            )
                    )
            )
        ]


{-| branch5: 
    List String
    -> String
    -> (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Case.Branch
-}
branch5 :
    List String
    -> String
    -> (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
branch5 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch5"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_5_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (\unpack_4_4_3_5_3_0 ->
                                        Elm.functionReduced
                                            "unpack"
                                            (arg1 unpack unpack0
                                                 unpack_4_3_5_3_0
                                                unpack_4_4_3_5_3_0
                                            )
                                    )
                            )
                    )
            )
        ]


{-| branch6: 
    List String
    -> String
    -> (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Case.Branch
-}
branch6 :
    List String
    -> String
    -> (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
branch6 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch6"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_5_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (\unpack_4_4_3_5_3_0 ->
                                        Elm.functionReduced
                                            "unpack"
                                            (\unpack_4_4_4_3_5_3_0 ->
                                                Elm.functionReduced
                                                    "unpack"
                                                    (arg1 unpack unpack0
                                                         unpack_4_3_5_3_0
                                                         unpack_4_4_3_5_3_0
                                                        unpack_4_4_4_3_5_3_0
                                                    )
                                            )
                                    )
                            )
                    )
            )
        ]


{-| branchWith: 
    List String
    -> String
    -> Int
    -> (List Elm.Expression -> Elm.Expression)
    -> Elm.Case.Branch
-}
branchWith :
    List String
    -> String
    -> Int
    -> (Elm.Expression -> Elm.Expression)
    -> Elm.Expression
branchWith arg arg0 arg1 arg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branchWith"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.int
                        , Type.function
                            [ Type.list
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg)
        , Elm.string arg0
        , Elm.int arg1
        , Elm.functionReduced "unpack" arg2
        ]


{-| listBranch: Int -> (List Elm.Expression -> Elm.Expression) -> Elm.Case.Branch -}
listBranch : Int -> (Elm.Expression -> Elm.Expression) -> Elm.Expression
listBranch arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "listBranch"
            , annotation =
                Just
                    (Type.function
                        [ Type.int
                        , Type.function
                            [ Type.list
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
        )
        [ Elm.int arg, Elm.functionReduced "unpack" arg0 ]


annotation_ : { branch : Type.Annotation }
annotation_ =
    { branch = Type.namedWith moduleName_ "Branch" [] }


call_ :
    { maybe : Elm.Expression -> Elm.Expression -> Elm.Expression
    , result : Elm.Expression -> Elm.Expression -> Elm.Expression
    , list : Elm.Expression -> Elm.Expression -> Elm.Expression
    , tuple : Elm.Expression -> Elm.Expression -> Elm.Expression
    , triple : Elm.Expression -> Elm.Expression -> Elm.Expression
    , custom : Elm.Expression -> Elm.Expression -> Elm.Expression
    , otherwise : Elm.Expression -> Elm.Expression
    , branch0 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branch1 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branch2 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branch3 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branch4 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branch5 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branch6 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , branchWith :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , listBranch : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { maybe =
        \arg arg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "maybe"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" []
                                , Type.record
                                    [ ( "nothing"
                                      , Type.namedWith [ "Elm" ] "Expression" []
                                      )
                                    , ( "just"
                                      , Type.function
                                            [ Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            ]
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                      )
                                    ]
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg, arg0 ]
    , result =
        \arg arg1 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "result"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" []
                                , Type.record
                                    [ ( "err"
                                      , Type.function
                                            [ Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            ]
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                      )
                                    , ( "ok"
                                      , Type.function
                                            [ Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            ]
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                      )
                                    ]
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg, arg1 ]
    , list =
        \arg arg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "list"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" []
                                , Type.record
                                    [ ( "empty"
                                      , Type.namedWith [ "Elm" ] "Expression" []
                                      )
                                    , ( "nonEmpty"
                                      , Type.function
                                            [ Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            , Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            ]
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                      )
                                    ]
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg, arg2 ]
    , tuple =
        \arg arg3 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "tuple"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" []
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg, arg3 ]
    , triple =
        \arg arg4 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "triple"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" []
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg, arg4 ]
    , custom =
        \arg arg5 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "custom"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" []
                                , Type.list
                                    (Type.namedWith
                                        [ "Elm", "Case" ]
                                        "Branch"
                                        []
                                    )
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg, arg5 ]
    , otherwise =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "otherwise"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg ]
    , branch0 =
        \arg arg7 arg8 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch0"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.namedWith [ "Elm" ] "Expression" []
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg7, arg8 ]
    , branch1 =
        \arg arg8 arg9 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch1"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg8, arg9 ]
    , branch2 =
        \arg arg9 arg10 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch2"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg9, arg10 ]
    , branch3 =
        \arg arg10 arg11 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch3"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg10, arg11 ]
    , branch4 =
        \arg arg11 arg12 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch4"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg11, arg12 ]
    , branch5 =
        \arg arg12 arg13 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch5"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg12, arg13 ]
    , branch6 =
        \arg arg13 arg14 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branch6"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg13, arg14 ]
    , branchWith =
        \arg arg14 arg15 arg16 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "branchWith"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.string
                                , Type.int
                                , Type.function
                                    [ Type.list
                                        (Type.namedWith
                                            [ "Elm" ]
                                            "Expression"
                                            []
                                        )
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg14, arg15, arg16 ]
    , listBranch =
        \arg arg15 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Case" ]
                    , name = "listBranch"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.int
                                , Type.function
                                    [ Type.list
                                        (Type.namedWith
                                            [ "Elm" ]
                                            "Expression"
                                            []
                                        )
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                            )
                    }
                )
                [ arg, arg15 ]
    }


values_ :
    { maybe : Elm.Expression
    , result : Elm.Expression
    , list : Elm.Expression
    , tuple : Elm.Expression
    , triple : Elm.Expression
    , custom : Elm.Expression
    , otherwise : Elm.Expression
    , branch0 : Elm.Expression
    , branch1 : Elm.Expression
    , branch2 : Elm.Expression
    , branch3 : Elm.Expression
    , branch4 : Elm.Expression
    , branch5 : Elm.Expression
    , branch6 : Elm.Expression
    , branchWith : Elm.Expression
    , listBranch : Elm.Expression
    }
values_ =
    { maybe =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "maybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.record
                            [ ( "nothing"
                              , Type.namedWith [ "Elm" ] "Expression" []
                              )
                            , ( "just"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    , result =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "result"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.record
                            [ ( "err"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            , ( "ok"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    , list =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "list"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.record
                            [ ( "empty"
                              , Type.namedWith [ "Elm" ] "Expression" []
                              )
                            , ( "nonEmpty"
                              , Type.function
                                    [ Type.namedWith [ "Elm" ] "Expression" []
                                    , Type.namedWith [ "Elm" ] "Expression" []
                                    ]
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                              )
                            ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    , tuple =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "tuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    , triple =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "triple"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    , custom =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "custom"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith [ "Elm" ] "Expression" []
                        , Type.list
                            (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    , otherwise =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "otherwise"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" [] ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch0 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch0"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch1 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch1"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" [] ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch2 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch2"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch3 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch3"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch4 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch4"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch5 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch5"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branch6 =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branch6"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.function
                            [ Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            , Type.namedWith [ "Elm" ] "Expression" []
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , branchWith =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "branchWith"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.string
                        , Type.int
                        , Type.function
                            [ Type.list
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    , listBranch =
        Elm.value
            { importFrom = [ "Elm", "Case" ]
            , name = "listBranch"
            , annotation =
                Just
                    (Type.function
                        [ Type.int
                        , Type.function
                            [ Type.list
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            ]
                            (Type.namedWith [ "Elm" ] "Expression" [])
                        ]
                        (Type.namedWith [ "Elm", "Case" ] "Branch" [])
                    )
            }
    }


