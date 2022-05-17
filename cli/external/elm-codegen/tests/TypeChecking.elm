module TypeChecking exposing (..)

import Elm
import Elm.Annotation as Type
import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Internal.Compiler as Compiler
import Test exposing (..)


successfullyInferredType expression =
    let
        ( _, details ) =
            Compiler.toExpressionDetails Compiler.startIndex expression
    in
    case details.annotation of
        Ok _ ->
            Expect.pass

        Err errs ->
            Expect.fail
                ("Failed to typecheck"
                    ++ String.join "\n"
                        (List.map Compiler.inferenceErrorToString errs)
                )


suite : Test
suite =
    describe "Type inference!"
        [ test "Strings" <|
            \_ ->
                successfullyInferredType (Elm.string "Hello!")
        , test "Bools" <|
            \_ ->
                successfullyInferredType (Elm.bool True)
        , test "Floats" <|
            \_ ->
                successfullyInferredType (Elm.float 0.6)
        , test "Int" <|
            \_ ->
                successfullyInferredType (Elm.int 6)
        , test "Maybe Bool" <|
            \_ ->
                successfullyInferredType (Elm.maybe (Just (Elm.bool True)))
        , test "List of Records" <|
            \_ ->
                successfullyInferredType
                    (Elm.list
                        [ Elm.record
                            [ Elm.field "first" (Elm.int 5)
                            , Elm.field "second" (Elm.tuple (Elm.string "hello") (Elm.int 5))
                            , Elm.field "first2" (Elm.int 5)
                            , Elm.field "second2" (Elm.tuple (Elm.string "hello") (Elm.int 5))
                            , Elm.field "first3" (Elm.int 5)
                            , Elm.field "second3" (Elm.tuple (Elm.string "hello") (Elm.int 5))
                            ]
                        ]
                    )
        , test "A simple plus function" <|
            \_ ->
                successfullyInferredType
                    (Elm.fn "myInt" <|
                        Elm.plus (Elm.int 5)
                    )
        , test "Function with list mapping" <|
            \_ ->
                successfullyInferredType
                    (Elm.fn "myArg" <|
                        \myArg ->
                            listMap
                                (\i ->
                                    Elm.plus (Elm.int 5) i
                                )
                                [ myArg
                                ]
                    )
        , test "Function that updates a literal elm record" <|
            \_ ->
                successfullyInferredType
                    (Elm.fn "myInt" <|
                        \myInt ->
                            Elm.updateRecord
                                (Elm.record
                                    [ Elm.field "first" (Elm.int 5)
                                    , Elm.field "second" (Elm.tuple (Elm.string "hello") (Elm.int 5))
                                    , Elm.field "first2" (Elm.int 5)
                                    , Elm.field "second2" (Elm.tuple (Elm.string "hello") (Elm.int 5))
                                    , Elm.field "first3" (Elm.int 5)
                                    , Elm.field "second3" (Elm.tuple (Elm.string "hello") (Elm.int 5))
                                    ]
                                )
                                [ Elm.field "first" myInt ]
                    )
        ]



{- HELPERS COPIED FROM GENRATED STUFF

   At some point we should just use the generated stuff directly.

-}


{-| Apply a function to every element of a list.

    map sqrt [ 1, 4, 9 ] == [ 1, 2, 3 ]

    map not [ True, False, True ] == [ False, True, False ]

So `map func [ a, b, c ]` is the same as `[ func a, func b, func c ]`

-}
listMap : (Elm.Expression -> Elm.Expression) -> List Elm.Expression -> Elm.Expression
listMap arg1 arg2 =
    Elm.apply
        (Elm.valueWith
            { importFrom = [ "List" ]
            , name = "map"
            , annotation =
                Just
                    (Type.function
                        [ Type.function [ Type.var "a" ] (Type.var "b")
                        , Type.list (Type.var "a")
                        ]
                        (Type.list (Type.var "b"))
                    )
            }
        )
        [ Elm.functionAdvanced
            [ ( "ar1", Type.var "a" ) ]
            (arg1
                (Elm.valueWith
                    { importFrom = []
                    , name = "ar1"
                    , annotation = Just (Type.var "a")
                    }
                )
            )
        , Elm.list arg2
        ]
