module Gen.Elm.Let exposing (call_, letIn, moduleName_, record, toExpression, tuple, value, values_)

{-| 
@docs moduleName_, letIn, value, tuple, record, toExpression, call_, values_
-}


import Elm
import Elm.Annotation as Type


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Elm", "Let" ]


{-| letIn: a -> Elm.Let.Let a -}
letIn : Elm.Expression -> Elm.Expression
letIn arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "letIn"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a" ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
        )
        [ arg ]


{-| value: String -> Elm.Expression -> Elm.Let.Let (Elm.Expression -> a) -> Elm.Let.Let a -}
value : String -> Elm.Expression -> Elm.Expression -> Elm.Expression
value arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "value"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        , Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                (Type.var "a")
                            ]
                        ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
        )
        [ Elm.string arg, arg0, arg1 ]


{-| tuple: 
    String
    -> String
    -> Elm.Expression
    -> Elm.Let.Let (( Elm.Expression, Elm.Expression ) -> a)
    -> Elm.Let.Let a
-}
tuple : String -> String -> Elm.Expression -> Elm.Expression -> Elm.Expression
tuple arg arg0 arg1 arg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "tuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        , Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.function
                                [ Type.tuple
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.var "a")
                            ]
                        ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
        )
        [ Elm.string arg, Elm.string arg0, arg1, arg2 ]


{-| record: 
    List String
    -> Elm.Expression
    -> Elm.Let.Let (List Elm.Expression -> a)
    -> Elm.Let.Let a
-}
record : List String -> Elm.Expression -> Elm.Expression -> Elm.Expression
record arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "record"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        , Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.function
                                [ Type.list
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.var "a")
                            ]
                        ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
        )
        [ Elm.list (List.map Elm.string arg), arg0, arg1 ]


{-| toExpression: Elm.Let.Let Elm.Expression -> Elm.Expression -}
toExpression : Elm.Expression -> Elm.Expression
toExpression arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "toExpression"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.namedWith [ "Elm" ] "Expression" [] ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
        )
        [ arg ]


call_ :
    { letIn : Elm.Expression -> Elm.Expression
    , value :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , tuple :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , record :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , toExpression : Elm.Expression -> Elm.Expression
    }
call_ =
    { letIn =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Let" ]
                    , name = "letIn"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a" ]
                                (Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg ]
    , value =
        \arg arg1 arg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Let" ]
                    , name = "value"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string
                                , Type.namedWith [ "Elm" ] "Expression" []
                                , Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.function
                                        [ Type.namedWith
                                            [ "Elm" ]
                                            "Expression"
                                            []
                                        ]
                                        (Type.var "a")
                                    ]
                                ]
                                (Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg1, arg2 ]
    , tuple =
        \arg arg2 arg3 arg4 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Let" ]
                    , name = "tuple"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.string
                                , Type.string
                                , Type.namedWith [ "Elm" ] "Expression" []
                                , Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.function
                                        [ Type.tuple
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                        ]
                                        (Type.var "a")
                                    ]
                                ]
                                (Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg2, arg3, arg4 ]
    , record =
        \arg arg3 arg4 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Let" ]
                    , name = "record"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.list Type.string
                                , Type.namedWith [ "Elm" ] "Expression" []
                                , Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.function
                                        [ Type.list
                                            (Type.namedWith
                                                [ "Elm" ]
                                                "Expression"
                                                []
                                            )
                                        ]
                                        (Type.var "a")
                                    ]
                                ]
                                (Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg3, arg4 ]
    , toExpression =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Elm", "Let" ]
                    , name = "toExpression"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Elm", "Let" ]
                                    "Let"
                                    [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                ]
                                (Type.namedWith [ "Elm" ] "Expression" [])
                            )
                    }
                )
                [ arg ]
    }


values_ :
    { letIn : Elm.Expression
    , value : Elm.Expression
    , tuple : Elm.Expression
    , record : Elm.Expression
    , toExpression : Elm.Expression
    }
values_ =
    { letIn =
        Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "letIn"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a" ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
    , value =
        Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "value"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        , Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.function
                                [ Type.namedWith [ "Elm" ] "Expression" [] ]
                                (Type.var "a")
                            ]
                        ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
    , tuple =
        Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "tuple"
            , annotation =
                Just
                    (Type.function
                        [ Type.string
                        , Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        , Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.function
                                [ Type.tuple
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.var "a")
                            ]
                        ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
    , record =
        Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "record"
            , annotation =
                Just
                    (Type.function
                        [ Type.list Type.string
                        , Type.namedWith [ "Elm" ] "Expression" []
                        , Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.function
                                [ Type.list
                                    (Type.namedWith [ "Elm" ] "Expression" [])
                                ]
                                (Type.var "a")
                            ]
                        ]
                        (Type.namedWith [ "Elm", "Let" ] "Let" [ Type.var "a" ])
                    )
            }
    , toExpression =
        Elm.value
            { importFrom = [ "Elm", "Let" ]
            , name = "toExpression"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Elm", "Let" ]
                            "Let"
                            [ Type.namedWith [ "Elm" ] "Expression" [] ]
                        ]
                        (Type.namedWith [ "Elm" ] "Expression" [])
                    )
            }
    }


