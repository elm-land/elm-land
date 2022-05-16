module Elm.Case exposing
    ( maybe, result, list
    , tuple, triple
    , custom
    , Branch, otherwise, branch0, branch1, branch2, branch3, branch4, branch5, branch6
    , branchWith, listBranch
    )

{-|

@docs maybe, result, list

@docs tuple, triple

@docs custom

@docs Branch, otherwise, branch0, branch1, branch2, branch3, branch4, branch5, branch6

@docs branchWith, listBranch

-}

import Dict exposing (Dict)
import Elm exposing (Expression)
import Elm.Annotation as Type
import Elm.Syntax.Expression as Exp
import Elm.Syntax.Node as Node
import Elm.Syntax.Pattern as Pattern
import Elm.Syntax.TypeAnnotation as Annotation
import Internal.Compiler as Compiler


captureCase :
    Compiler.Expression
    -> Compiler.Index
    -> List Branch
    ->
        ( Compiler.ExpressionDetails
        , { index : Compiler.Index
          , cases : List ( Node.Node Pattern.Pattern, Node.Node Exp.Expression )
          , imports : List Compiler.Module
          , annotation : Maybe (Result (List Compiler.InferenceError) Compiler.Inference)
          }
        )
captureCase mainExpression index branches =
    let
        ( branchIndex, mainExpressionDetails ) =
            Compiler.toExpressionDetails index mainExpression
    in
    ( mainExpressionDetails
    , List.foldl
        captureCaseHelper
        { index = branchIndex
        , cases = []
        , imports = []
        , annotation = Nothing
        }
        branches
    )


captureCaseHelper :
    Branch
    ->
        { index : Compiler.Index
        , cases : List ( Node.Node Pattern.Pattern, Node.Node Exp.Expression )
        , imports : List Compiler.Module
        , annotation : Maybe (Result (List Compiler.InferenceError) Compiler.Inference)
        }
    ->
        { index : Compiler.Index
        , cases : List ( Node.Node Pattern.Pattern, Node.Node Exp.Expression )
        , imports : List Compiler.Module
        , annotation : Maybe (Result (List Compiler.InferenceError) Compiler.Inference)
        }
captureCaseHelper (Branch toBranch) accum =
    let
        ( branchIndex, pattern, caseExpression ) =
            toBranch accum.index

        ( newIndex, exp ) =
            Compiler.toExpressionDetails branchIndex caseExpression
    in
    { index = newIndex
    , cases = ( Compiler.nodify pattern, Compiler.nodify exp.expression ) :: accum.cases
    , imports = accum.imports ++ exp.imports
    , annotation =
        case accum.annotation of
            Nothing ->
                Just exp.annotation

            Just (Ok gatheredAnnotation) ->
                Compiler.unifyOn
                    (Compiler.Annotation
                        { annotation = gatheredAnnotation.type_
                        , aliases = gatheredAnnotation.aliases
                        , imports = []
                        }
                    )
                    (exp.annotation
                        |> combineInferences gatheredAnnotation.inferences
                    )
                    |> Just

            Just err ->
                Just err
    }


combineInferences :
    Dict.Dict String Annotation.TypeAnnotation
    -> Result (List Compiler.InferenceError) Compiler.Inference
    -> Result (List Compiler.InferenceError) Compiler.Inference
combineInferences infs infResult =
    case infResult of
        Ok inferred ->
            Ok { inferred | inferences = Compiler.mergeInferences infs inferred.inferences }

        Err err ->
            Err err


{-|

    Elm.fn "myMaybe" <|
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

-}
maybe :
    Expression
    ->
        { nothing : Expression
        , just : Expression -> Expression
        }
    -> Expression
maybe mainExpression branches =
    Compiler.Expression
        (\index ->
            let
                ( expr, gathered ) =
                    captureCase mainExpression
                        index
                        [ Branch
                            (\branchIndex ->
                                ( branchIndex
                                , Pattern.NamedPattern { moduleName = [], name = "Nothing" } []
                                , branches.nothing
                                )
                            )
                        , Branch
                            (\branchIndex ->
                                let
                                    ( justIndex, justName, justExp ) =
                                        Compiler.var branchIndex "just"
                                in
                                ( justIndex
                                , Pattern.NamedPattern { moduleName = [], name = "Just" } [ Compiler.nodify (Pattern.VarPattern justName) ]
                                , branches.just justExp
                                )
                            )
                        ]
            in
            { expression =
                Exp.CaseExpression
                    { expression = Compiler.nodify expr.expression
                    , cases = List.reverse gathered.cases
                    }
            , annotation =
                case gathered.annotation of
                    Nothing ->
                        Err [ Compiler.EmptyCaseStatement ]

                    Just ann ->
                        ann
            , imports = expr.imports ++ gathered.imports
            }
        )


{-|

    Elm.fn "myTuple" <|
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

-}
tuple :
    Expression
    -> (Expression -> Expression -> Expression)
    -> Expression
tuple mainExpression branches =
    Compiler.Expression <|
        \index ->
            let
                ( expr, gathered ) =
                    captureCase mainExpression
                        (Compiler.dive index)
                        [ Branch
                            (\branchIndex ->
                                let
                                    ( firstIndex, firstName, firstExp ) =
                                        Compiler.var branchIndex "first"

                                    ( secondIndex, secondName, secondExp ) =
                                        Compiler.var firstIndex "second"
                                in
                                ( secondIndex
                                , Pattern.TuplePattern
                                    [ Compiler.nodify (Pattern.VarPattern firstName)
                                    , Compiler.nodify (Pattern.VarPattern secondName)
                                    ]
                                , branches firstExp secondExp
                                )
                            )
                        ]
            in
            { expression =
                Exp.CaseExpression
                    { expression = Compiler.nodify expr.expression
                    , cases = List.reverse gathered.cases
                    }
            , annotation =
                case gathered.annotation of
                    Nothing ->
                        Err [ Compiler.EmptyCaseStatement ]

                    Just ann ->
                        ann
            , imports = expr.imports ++ gathered.imports
            }


{-|

    Elm.fn "myTriple" <|
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

-}
triple :
    Expression
    -> (Expression -> Expression -> Expression -> Expression)
    -> Expression
triple mainExpression branches =
    Compiler.Expression <|
        \index ->
            let
                ( expr, gathered ) =
                    captureCase mainExpression
                        index
                        [ Branch
                            (\branchIndex ->
                                let
                                    ( firstIndex, firstName, firstExp ) =
                                        Compiler.var branchIndex "first"

                                    ( secondIndex, secondName, secondExp ) =
                                        Compiler.var firstIndex "second"

                                    ( thirdIndex, thirdName, thirdExp ) =
                                        Compiler.var secondIndex "third"
                                in
                                ( thirdIndex
                                , Pattern.TuplePattern
                                    [ Compiler.nodify (Pattern.VarPattern firstName)
                                    , Compiler.nodify (Pattern.VarPattern secondName)
                                    , Compiler.nodify (Pattern.VarPattern thirdName)
                                    ]
                                , branches firstExp secondExp thirdExp
                                )
                            )
                        ]
            in
            { expression =
                Exp.CaseExpression
                    { expression = Compiler.nodify expr.expression
                    , cases = List.reverse gathered.cases
                    }
            , annotation =
                case gathered.annotation of
                    Nothing ->
                        Err [ Compiler.EmptyCaseStatement ]

                    Just ann ->
                        ann
            , imports = expr.imports ++ gathered.imports
            }


{-|

    Elm.fn "myResult" <|
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

-}
result :
    Expression
    ->
        { err : Expression -> Expression
        , ok : Expression -> Expression
        }
    -> Expression
result mainExpression branches =
    Compiler.Expression <|
        \index ->
            let
                ( expr, gathered ) =
                    captureCase mainExpression
                        (Compiler.dive index)
                        [ Branch
                            (\branchIndex ->
                                let
                                    ( okIndex, okName, okExp ) =
                                        Compiler.var branchIndex "ok"
                                in
                                ( okIndex
                                , Pattern.NamedPattern { moduleName = [], name = "Ok" }
                                    [ Compiler.nodify (Pattern.VarPattern okName) ]
                                , branches.err okExp
                                )
                            )
                        , Branch
                            (\branchIndex ->
                                let
                                    ( errIndex, errName, errExp ) =
                                        Compiler.var branchIndex "err"
                                in
                                ( errIndex
                                , Pattern.NamedPattern { moduleName = [], name = "Err" }
                                    [ Compiler.nodify (Pattern.VarPattern errName) ]
                                , branches.ok errExp
                                )
                            )
                        ]
            in
            { expression =
                Exp.CaseExpression
                    { expression = Compiler.nodify expr.expression
                    , cases = List.reverse gathered.cases
                    }
            , annotation =
                case gathered.annotation of
                    Nothing ->
                        Err [ Compiler.EmptyCaseStatement ]

                    Just ann ->
                        ann
            , imports = expr.imports ++ gathered.imports
            }


{-|

    Elm.fn "myList" <|
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

-}
list :
    Expression
    ->
        { empty : Expression
        , nonEmpty : Expression -> Expression -> Expression
        }
    -> Expression
list mainExpression branches =
    Compiler.Expression <|
        \index ->
            let
                ( expr, gathered ) =
                    captureCase mainExpression
                        (Compiler.dive index)
                        [ Branch
                            (\branchIndex ->
                                ( branchIndex
                                , Pattern.ListPattern []
                                , branches.empty
                                )
                            )
                        , Branch
                            (\branchIndex ->
                                let
                                    ( topIndex, topName, topExp ) =
                                        Compiler.var branchIndex "top"

                                    ( remainIndex, remainName, remainExp ) =
                                        Compiler.var topIndex "remaining"
                                in
                                ( remainIndex
                                , Pattern.UnConsPattern
                                    (Compiler.nodify (Pattern.VarPattern topName))
                                    (Compiler.nodify (Pattern.VarPattern remainName))
                                , branches.nonEmpty
                                    topExp
                                    remainExp
                                )
                            )
                        ]
            in
            { expression =
                Exp.CaseExpression
                    { expression = Compiler.nodify expr.expression
                    , cases = List.reverse gathered.cases
                    }
            , annotation =
                case gathered.annotation of
                    Nothing ->
                        Err [ Compiler.EmptyCaseStatement ]

                    Just ann ->
                        ann
            , imports = expr.imports ++ gathered.imports
            }


{-|

    Elm.fn "maybeString" <|
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

-}
custom :
    Expression
    -> List Branch
    -> Expression
custom mainExpression branches =
    Compiler.Expression <|
        \index ->
            let
                ( expr, gathered ) =
                    captureCase mainExpression
                        (Compiler.dive index)
                        branches
            in
            { expression =
                Exp.CaseExpression
                    { expression = Compiler.nodify expr.expression
                    , cases = List.reverse gathered.cases
                    }
            , annotation =
                case gathered.annotation of
                    Nothing ->
                        Err [ Compiler.EmptyCaseStatement ]

                    Just ann ->
                        ann
            , imports = expr.imports ++ gathered.imports
            }


{-| -}
type Branch
    = Branch (Compiler.Index -> ( Compiler.Index, Pattern.Pattern, Expression ))


{-| -}
branch0 : List String -> String -> Expression -> Branch
branch0 mod name exp =
    Branch
        (\index ->
            ( index
            , Pattern.NamedPattern { moduleName = mod, name = name } []
            , exp
            )
        )


{-| A catchall branch in case you want the case to be nonexhaustive.
-}
otherwise : (Expression -> Expression) -> Branch
otherwise toExp =
    Branch
        (\index ->
            let
                ( otherwiseIndex, otherwiseName, otherwiseExp ) =
                    Compiler.var index "otherwise"
            in
            ( otherwiseIndex
            , Pattern.VarPattern otherwiseName
            , toExp otherwiseExp
            )
        )


{-| -}
branch1 : List String -> String -> (Expression -> Expression) -> Branch
branch1 moduleName name toExp =
    Branch
        (\index ->
            let
                ( oneIndex, oneName, oneExp ) =
                    Compiler.var index "one"
            in
            ( oneIndex
            , Pattern.NamedPattern { moduleName = moduleName, name = name }
                [ Compiler.nodify (Pattern.VarPattern oneName) ]
            , toExp oneExp
            )
        )


{-| -}
branch2 : List String -> String -> (Expression -> Expression -> Expression) -> Branch
branch2 moduleName name toExp =
    Branch
        (\index ->
            let
                ( oneIndex, oneName, oneExp ) =
                    Compiler.var index "one"

                ( twoIndex, twoName, twoExp ) =
                    Compiler.var oneIndex "two"
            in
            ( twoIndex
            , Pattern.NamedPattern { moduleName = [], name = name }
                [ Compiler.nodify (Pattern.VarPattern oneName)
                , Compiler.nodify (Pattern.VarPattern twoName)
                ]
            , toExp oneExp twoExp
            )
        )


{-| -}
branch3 : List String -> String -> (Expression -> Expression -> Expression -> Expression) -> Branch
branch3 moduleName name toExp =
    Branch
        (\index ->
            let
                ( oneIndex, oneName, oneExp ) =
                    Compiler.var index "one"

                ( twoIndex, twoName, twoExp ) =
                    Compiler.var oneIndex "two"

                ( threeIndex, threeName, threeExp ) =
                    Compiler.var twoIndex "three"
            in
            ( threeIndex
            , Pattern.NamedPattern { moduleName = moduleName, name = name }
                [ Compiler.nodify (Pattern.VarPattern oneName)
                , Compiler.nodify (Pattern.VarPattern twoName)
                , Compiler.nodify (Pattern.VarPattern threeName)
                ]
            , toExp oneExp twoExp threeExp
            )
        )


{-| -}
branch4 : List String -> String -> (Expression -> Expression -> Expression -> Expression -> Expression) -> Branch
branch4 moduleName name toExp =
    Branch
        (\index ->
            let
                ( oneIndex, oneName, oneExp ) =
                    Compiler.var index "one"

                ( twoIndex, twoName, twoExp ) =
                    Compiler.var oneIndex "two"

                ( threeIndex, threeName, threeExp ) =
                    Compiler.var twoIndex "three"

                ( fourIndex, fourName, fourExp ) =
                    Compiler.var threeIndex "four"
            in
            ( fourIndex
            , Pattern.NamedPattern { moduleName = moduleName, name = name }
                [ Compiler.nodify (Pattern.VarPattern oneName)
                , Compiler.nodify (Pattern.VarPattern twoName)
                , Compiler.nodify (Pattern.VarPattern threeName)
                , Compiler.nodify (Pattern.VarPattern fourName)
                ]
            , toExp oneExp twoExp threeExp fourExp
            )
        )


{-| -}
branch5 :
    List String
    -> String
    ->
        (Expression
         -> Expression
         -> Expression
         -> Expression
         -> Expression
         -> Expression
        )
    -> Branch
branch5 moduleName name toExp =
    Branch
        (\index ->
            let
                ( oneIndex, oneName, oneExp ) =
                    Compiler.var index "one"

                ( twoIndex, twoName, twoExp ) =
                    Compiler.var oneIndex "two"

                ( threeIndex, threeName, threeExp ) =
                    Compiler.var twoIndex "three"

                ( fourIndex, fourName, fourExp ) =
                    Compiler.var threeIndex "four"

                ( fiveIndex, fiveName, fiveExp ) =
                    Compiler.var fourIndex "five"
            in
            ( fiveIndex
            , Pattern.NamedPattern { moduleName = moduleName, name = name }
                [ Compiler.nodify (Pattern.VarPattern oneName)
                , Compiler.nodify (Pattern.VarPattern twoName)
                , Compiler.nodify (Pattern.VarPattern threeName)
                , Compiler.nodify (Pattern.VarPattern fourName)
                , Compiler.nodify (Pattern.VarPattern fiveName)
                ]
            , toExp oneExp twoExp threeExp fourExp fiveExp
            )
        )


{-| -}
branch6 :
    List String
    -> String
    ->
        (Expression
         -> Expression
         -> Expression
         -> Expression
         -> Expression
         -> Expression
         -> Expression
        )
    -> Branch
branch6 moduleName name toExp =
    Branch
        (\index ->
            let
                ( oneIndex, oneName, oneExp ) =
                    Compiler.var index "one"

                ( twoIndex, twoName, twoExp ) =
                    Compiler.var oneIndex "two"

                ( threeIndex, threeName, threeExp ) =
                    Compiler.var twoIndex "three"

                ( fourIndex, fourName, fourExp ) =
                    Compiler.var threeIndex "four"

                ( fiveIndex, fiveName, fiveExp ) =
                    Compiler.var fourIndex "five"

                ( sixIndex, sixName, sixExp ) =
                    Compiler.var fiveIndex "six"
            in
            ( sixIndex
            , Pattern.NamedPattern { moduleName = moduleName, name = name }
                [ Compiler.nodify (Pattern.VarPattern oneName)
                , Compiler.nodify (Pattern.VarPattern twoName)
                , Compiler.nodify (Pattern.VarPattern threeName)
                , Compiler.nodify (Pattern.VarPattern fourName)
                , Compiler.nodify (Pattern.VarPattern fiveName)
                , Compiler.nodify (Pattern.VarPattern sixName)
                ]
            , toExp oneExp twoExp threeExp fourExp fiveExp sixExp
            )
        )


{-| -}
branchWith : List String -> String -> Int -> (List Expression -> Expression) -> Branch
branchWith moduleName name arity toExp =
    Branch
        (\index ->
            let
                ( patterns, args ) =
                    List.range 1 arity
                        |> List.map
                            (\i ->
                                let
                                    ( _, varName, varExp ) =
                                        Compiler.var index <| "arg" ++ String.fromInt i
                                in
                                ( Compiler.nodify (Pattern.VarPattern varName)
                                , varExp
                                )
                            )
                        |> List.unzip
            in
            ( Compiler.next index
            , Pattern.NamedPattern { moduleName = moduleName, name = name } patterns
            , toExp args
            )
        )


{-| -}
listBranch : Int -> (List Expression -> Expression) -> Branch
listBranch arity toExp =
    Branch
        (\index ->
            let
                ( pattern, args ) =
                    List.foldl
                        (\i ( listPattern, currentArgs ) ->
                            let
                                ( _, varName, varExp ) =
                                    Compiler.var index <| "arg" ++ String.fromInt i
                            in
                            ( Compiler.nodify (Pattern.VarPattern varName) :: listPattern
                            , varExp :: currentArgs
                            )
                        )
                        ( []
                        , []
                        )
                        (List.drop 1 (List.range 0 arity))
            in
            ( Compiler.next index
            , Pattern.ListPattern (List.reverse pattern)
            , toExp (List.reverse args)
            )
        )
