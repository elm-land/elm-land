module Gen.Result exposing (andThen, annotation_, call_, caseOf_, fromMaybe, make_, map, map2, map3, map4, map5, mapError, moduleName_, toMaybe, values_, withDefault)

{-| 
@docs moduleName_, map, map2, map3, map4, map5, andThen, withDefault, toMaybe, fromMaybe, mapError, annotation_, make_, caseOf_, call_, values_
-}


import Elm
import Elm.Annotation as Type
import Elm.Case


{-| The name of this module. -}
moduleName_ : List String
moduleName_ =
    [ "Result" ]


{-| Apply a function to a result. If the result is `Ok`, it will be converted.
If the result is an `Err`, the same error value will propagate through.

    map sqrt (Ok 4.0)          == Ok 2.0
    map sqrt (Err "bad input") == Err "bad input"

map: (a -> value) -> Result.Result x a -> Result.Result x value
-}
map : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
map arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| Apply a function if both results are `Ok`. If not, the first `Err` will
propagate through.

    map2 max (Ok 42)   (Ok 13)   == Ok 42
    map2 max (Err "x") (Ok 13)   == Err "x"
    map2 max (Ok 42)   (Err "y") == Err "y"
    map2 max (Err "x") (Err "y") == Err "x"

This can be useful if you have two computations that may fail, and you want
to put them together quickly.

map2: 
    (a -> b -> value)
    -> Result.Result x a
    -> Result.Result x b
    -> Result.Result x value
-}
map2 :
    (Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map2 arg arg0 arg1 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "map2"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack -> Elm.functionReduced "unpack" (arg unpack))
        , arg0
        , arg1
        ]


{-| map3: 
    (a -> b -> c -> value)
    -> Result.Result x a
    -> Result.Result x b
    -> Result.Result x c
    -> Result.Result x value
-}
map3 :
    (Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map3 arg arg0 arg1 arg2 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "map3"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b", Type.var "c" ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "c" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced "unpack" (arg unpack unpack0)
                    )
            )
        , arg0
        , arg1
        , arg2
        ]


{-| map4: 
    (a -> b -> c -> d -> value)
    -> Result.Result x a
    -> Result.Result x b
    -> Result.Result x c
    -> Result.Result x d
    -> Result.Result x value
-}
map4 :
    (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map4 arg arg0 arg1 arg2 arg3 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "map4"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "d" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_3_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (arg unpack unpack0 unpack_4_3_3_3_0)
                            )
                    )
            )
        , arg0
        , arg1
        , arg2
        , arg3
        ]


{-| map5: 
    (a -> b -> c -> d -> e -> value)
    -> Result.Result x a
    -> Result.Result x b
    -> Result.Result x c
    -> Result.Result x d
    -> Result.Result x e
    -> Result.Result x value
-}
map5 :
    (Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression)
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
    -> Elm.Expression
map5 arg arg0 arg1 arg2 arg3 arg4 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "map5"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            , Type.var "e"
                            ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "d" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "e" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced
            "unpack"
            (\unpack ->
                Elm.functionReduced
                    "unpack"
                    (\unpack0 ->
                        Elm.functionReduced
                            "unpack"
                            (\unpack_4_3_3_3_0 ->
                                Elm.functionReduced
                                    "unpack"
                                    (\unpack_4_4_3_3_3_0 ->
                                        Elm.functionReduced
                                            "unpack"
                                            (arg unpack unpack0 unpack_4_3_3_3_0
                                                unpack_4_4_3_3_3_0
                                            )
                                    )
                            )
                    )
            )
        , arg0
        , arg1
        , arg2
        , arg3
        , arg4
        ]


{-| Chain together a sequence of computations that may fail. It is helpful
to see its definition:

    andThen : (a -> Result e b) -> Result e a -> Result e b
    andThen callback result =
        case result of
          Ok value -> callback value
          Err msg -> Err msg

This means we only continue with the callback if things are going well. For
example, say you need to use (`toInt : String -> Result String Int`) to parse
a month and make sure it is between 1 and 12:

    toValidMonth : Int -> Result String Int
    toValidMonth month =
        if month >= 1 && month <= 12
            then Ok month
            else Err "months must be between 1 and 12"

    toMonth : String -> Result String Int
    toMonth rawString =
        toInt rawString
          |> andThen toValidMonth

    -- toMonth "4" == Ok 4
    -- toMonth "9" == Ok 9
    -- toMonth "a" == Err "cannot parse to an Int"
    -- toMonth "0" == Err "months must be between 1 and 12"

This allows us to come out of a chain of operations with quite a specific error
message. It is often best to create a custom type that explicitly represents
the exact ways your computation may fail. This way it is easy to handle in your
code.

andThen: (a -> Result.Result x b) -> Result.Result x a -> Result.Result x b
-}
andThen : (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
andThen arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "andThen"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.namedWith
                                [ "Result" ]
                                "Result"
                                [ Type.var "x", Type.var "b" ]
                            )
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


{-| If the result is `Ok` return the value, but if the result is an `Err` then
return a given default value. The following examples try to parse integers.

    Result.withDefault 0 (Ok 123)   == 123
    Result.withDefault 0 (Err "no") == 0

withDefault: a -> Result.Result x a -> a
-}
withDefault : Elm.Expression -> Elm.Expression -> Elm.Expression
withDefault arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "withDefault"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a"
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.var "a")
                    )
            }
        )
        [ arg, arg0 ]


{-| Convert to a simpler `Maybe` if the actual error message is not needed or
you need to interact with some code that primarily uses maybes.

    parseInt : String -> Result ParseError Int

    maybeParseInt : String -> Maybe Int
    maybeParseInt string =
        toMaybe (parseInt string)

toMaybe: Result.Result x a -> Maybe a
-}
toMaybe : Elm.Expression -> Elm.Expression
toMaybe arg =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "toMaybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.maybe (Type.var "a"))
                    )
            }
        )
        [ arg ]


{-| Convert from a simple `Maybe` to interact with some code that primarily
uses `Results`.

    parseInt : String -> Maybe Int

    resultParseInt : String -> Result String Int
    resultParseInt string =
        fromMaybe ("error parsing string: " ++ toString string) (parseInt string)

fromMaybe: x -> Maybe a -> Result.Result x a
-}
fromMaybe : Elm.Expression -> Elm.Expression -> Elm.Expression
fromMaybe arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "fromMaybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "x", Type.maybe (Type.var "a") ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        )
                    )
            }
        )
        [ arg, arg0 ]


{-| Transform an `Err` value. For example, say the errors we get have too much
information:

    parseInt : String -> Result ParseError Int

    type alias ParseError =
        { message : String
        , code : Int
        , position : (Int,Int)
        }

    mapError .message (parseInt "123") == Ok 123
    mapError .message (parseInt "abc") == Err "char 'a' is not a number"

mapError: (x -> y) -> Result.Result x a -> Result.Result y a
-}
mapError :
    (Elm.Expression -> Elm.Expression) -> Elm.Expression -> Elm.Expression
mapError arg arg0 =
    Elm.apply
        (Elm.value
            { importFrom = [ "Result" ]
            , name = "mapError"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "x" ] (Type.var "y")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "y", Type.var "a" ]
                        )
                    )
            }
        )
        [ Elm.functionReduced "unpack" arg, arg0 ]


annotation_ : { result : Type.Annotation -> Type.Annotation -> Type.Annotation }
annotation_ =
    { result = \arg0 arg1 -> Type.namedWith moduleName_ "Result" [ arg0, arg1 ]
    }


make_ :
    { ok : Elm.Expression -> Elm.Expression
    , err : Elm.Expression -> Elm.Expression
    }
make_ =
    { ok =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "Ok"
                    , annotation =
                        Just
                            (Type.namedWith
                                []
                                "Result"
                                [ Type.var "error", Type.var "value" ]
                            )
                    }
                )
                [ ar0 ]
    , err =
        \ar0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "Err"
                    , annotation =
                        Just
                            (Type.namedWith
                                []
                                "Result"
                                [ Type.var "error", Type.var "value" ]
                            )
                    }
                )
                [ ar0 ]
    }


caseOf_ :
    { result :
        Elm.Expression
        -> { tags
            | ok : Elm.Expression -> Elm.Expression
            , err : Elm.Expression -> Elm.Expression
        }
        -> Elm.Expression
    }
caseOf_ =
    { result =
        \expresssion tags ->
            Elm.Case.custom
                expresssion
                [ Elm.Case.branch1 [ "Result" ] "Ok" tags.ok
                , Elm.Case.branch1 [ "Result" ] "Err" tags.err
                ]
    }


call_ :
    { map : Elm.Expression -> Elm.Expression -> Elm.Expression
    , map2 :
        Elm.Expression -> Elm.Expression -> Elm.Expression -> Elm.Expression
    , map3 :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , map4 :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , map5 :
        Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
        -> Elm.Expression
    , andThen : Elm.Expression -> Elm.Expression -> Elm.Expression
    , withDefault : Elm.Expression -> Elm.Expression -> Elm.Expression
    , toMaybe : Elm.Expression -> Elm.Expression
    , fromMaybe : Elm.Expression -> Elm.Expression -> Elm.Expression
    , mapError : Elm.Expression -> Elm.Expression -> Elm.Expression
    }
call_ =
    { map =
        \arg arg0 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "map"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.var "value")
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "value" ]
                                )
                            )
                    }
                )
                [ arg, arg0 ]
    , map2 =
        \arg arg1 arg2 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "map2"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b" ]
                                    (Type.var "value")
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "b" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "value" ]
                                )
                            )
                    }
                )
                [ arg, arg1, arg2 ]
    , map3 =
        \arg arg2 arg3 arg4 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "map3"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a", Type.var "b", Type.var "c" ]
                                    (Type.var "value")
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "b" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "c" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "value" ]
                                )
                            )
                    }
                )
                [ arg, arg2, arg3, arg4 ]
    , map4 =
        \arg arg3 arg4 arg5 arg6 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "map4"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a"
                                    , Type.var "b"
                                    , Type.var "c"
                                    , Type.var "d"
                                    ]
                                    (Type.var "value")
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "b" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "c" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "d" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "value" ]
                                )
                            )
                    }
                )
                [ arg, arg3, arg4, arg5, arg6 ]
    , map5 =
        \arg arg4 arg5 arg6 arg7 arg8 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "map5"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a"
                                    , Type.var "b"
                                    , Type.var "c"
                                    , Type.var "d"
                                    , Type.var "e"
                                    ]
                                    (Type.var "value")
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "b" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "c" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "d" ]
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "e" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "value" ]
                                )
                            )
                    }
                )
                [ arg, arg4, arg5, arg6, arg7, arg8 ]
    , andThen =
        \arg arg5 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "andThen"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function
                                    [ Type.var "a" ]
                                    (Type.namedWith
                                        [ "Result" ]
                                        "Result"
                                        [ Type.var "x", Type.var "b" ]
                                    )
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "b" ]
                                )
                            )
                    }
                )
                [ arg, arg5 ]
    , withDefault =
        \arg arg6 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "withDefault"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "a"
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.var "a")
                            )
                    }
                )
                [ arg, arg6 ]
    , toMaybe =
        \arg ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "toMaybe"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.maybe (Type.var "a"))
                            )
                    }
                )
                [ arg ]
    , fromMaybe =
        \arg arg8 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "fromMaybe"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.var "x", Type.maybe (Type.var "a") ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg8 ]
    , mapError =
        \arg arg9 ->
            Elm.apply
                (Elm.value
                    { importFrom = [ "Result" ]
                    , name = "mapError"
                    , annotation =
                        Just
                            (Type.function
                                [ Type.function [ Type.var "x" ] (Type.var "y")
                                , Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "x", Type.var "a" ]
                                ]
                                (Type.namedWith
                                    [ "Result" ]
                                    "Result"
                                    [ Type.var "y", Type.var "a" ]
                                )
                            )
                    }
                )
                [ arg, arg9 ]
    }


values_ :
    { map : Elm.Expression
    , map2 : Elm.Expression
    , map3 : Elm.Expression
    , map4 : Elm.Expression
    , map5 : Elm.Expression
    , andThen : Elm.Expression
    , withDefault : Elm.Expression
    , toMaybe : Elm.Expression
    , fromMaybe : Elm.Expression
    , mapError : Elm.Expression
    }
values_ =
    { map =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
    , map2 =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "map2"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b" ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
    , map3 =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "map3"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a", Type.var "b", Type.var "c" ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "c" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
    , map4 =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "map4"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "d" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
    , map5 =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "map5"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a"
                            , Type.var "b"
                            , Type.var "c"
                            , Type.var "d"
                            , Type.var "e"
                            ]
                            (Type.var "value")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "c" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "d" ]
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "e" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "value" ]
                        )
                    )
            }
    , andThen =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "andThen"
            , annotation =
                Just
                    (Type.function
                        [ Type.function
                            [ Type.var "a" ]
                            (Type.namedWith
                                [ "Result" ]
                                "Result"
                                [ Type.var "x", Type.var "b" ]
                            )
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "b" ]
                        )
                    )
            }
    , withDefault =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "withDefault"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "a"
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.var "a")
                    )
            }
    , toMaybe =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "toMaybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.maybe (Type.var "a"))
                    )
            }
    , fromMaybe =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "fromMaybe"
            , annotation =
                Just
                    (Type.function
                        [ Type.var "x", Type.maybe (Type.var "a") ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        )
                    )
            }
    , mapError =
        Elm.value
            { importFrom = [ "Result" ]
            , name = "mapError"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "x" ] (Type.var "y")
                        , Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "x", Type.var "a" ]
                        ]
                        (Type.namedWith
                            [ "Result" ]
                            "Result"
                            [ Type.var "y", Type.var "a" ]
                        )
                    )
            }
    }


