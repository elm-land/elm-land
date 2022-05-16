module Elm.Let exposing
    ( letIn
    , value, tuple, record
    , toExpression
    )

{-|

@docs letIn

@docs value, tuple, record

@docs toExpression

-}

import Dict
import Elm exposing (Expression)
import Elm.Annotation
import Elm.Syntax.Expression as Exp
import Elm.Syntax.Node as Node
import Elm.Syntax.Pattern as Pattern
import Elm.Syntax.TypeAnnotation as Annotation
import Internal.Compiler as Compiler


{-| -}
type Let a
    = Let
        (Compiler.Index
         -> ( List LetDeclarations, a )
        )


type LetDeclarations
    = Value String Expression
    | Tuple String String Expression
    | Record (List String) Expression


{-| -}
letIn : a -> Let a
letIn return =
    Let (\index -> ( [], return ))


with : Let a -> Let (a -> b) -> Let b
with (Let toScopeA) (Let toScopeAB) =
    Let
        (\index ->
            let
                ( scopeA, a ) =
                    toScopeA index

                ( scopeToB, toB ) =
                    toScopeAB (Compiler.next index)
            in
            ( scopeA ++ scopeToB
            , toB a
            )
        )


{-| -}
value : String -> Expression -> Let (Expression -> a) -> Let a
value desiredName valueExpr sourceLet =
    with
        (Let
            (\index ->
                let
                    ( name, valueReference ) =
                        asValue index desiredName valueExpr
                in
                ( [ Value name valueExpr ]
                , valueReference
                )
            )
        )
        sourceLet


asValue : Compiler.Index -> String -> Expression -> ( String, Expression )
asValue index desiredName sourceExpression =
    let
        ( name, newIndex ) =
            Compiler.getName desiredName index
    in
    ( name
    , Compiler.Expression <|
        \_ ->
            { expression =
                Exp.FunctionOrValue []
                    (Compiler.sanitize name)
            , annotation =
                let
                    ( _, sourceDetails ) =
                        Compiler.toExpressionDetails newIndex sourceExpression
                in
                sourceDetails.annotation
            , imports =
                []
            }
    )


{-| -}
tuple : String -> String -> Expression -> Let (( Expression, Expression ) -> a) -> Let a
tuple desiredNameOne desiredNameTwo valueExpr sourceLet =
    sourceLet
        |> with
            (Let
                (\index ->
                    let
                        myTuple =
                            unpackTuple index desiredNameOne desiredNameTwo valueExpr
                    in
                    ( [ Tuple myTuple.one.name myTuple.two.name valueExpr ]
                    , ( myTuple.one.reference, myTuple.two.reference )
                    )
                )
            )


unpackTuple :
    Compiler.Index
    -> String
    -> String
    -> Expression
    ->
        { one : { name : String, reference : Expression }
        , two : { name : String, reference : Expression }
        }
unpackTuple index desiredNameOne desiredNameTwo sourceExpression =
    let
        ( oneName, oneIndex ) =
            Compiler.getName desiredNameOne index

        ( twoName, twoIndex ) =
            Compiler.getName desiredNameTwo oneIndex

        ( newIndex, sourceDetails ) =
            Compiler.toExpressionDetails twoIndex sourceExpression
    in
    { one =
        { name = oneName
        , reference =
            Compiler.Expression <|
                \_ ->
                    { expression =
                        Exp.FunctionOrValue []
                            (Compiler.sanitize oneName)
                    , annotation =
                        case sourceDetails.annotation of
                            Err e ->
                                Err e

                            Ok inference ->
                                case inference.type_ of
                                    Annotation.Tupled [ Node.Node _ oneType, Node.Node _ twoType ] ->
                                        Ok
                                            { type_ = oneType
                                            , inferences = Dict.empty
                                            , aliases = inference.aliases
                                            }

                                    _ ->
                                        Err []
                    , imports =
                        []
                    }
        }
    , two =
        { name = twoName
        , reference =
            Compiler.Expression <|
                \_ ->
                    { expression =
                        Exp.FunctionOrValue []
                            (Compiler.sanitize oneName)
                    , annotation =
                        case sourceDetails.annotation of
                            Err e ->
                                Err e

                            Ok inference ->
                                case inference.type_ of
                                    Annotation.Tupled [ Node.Node _ oneType, Node.Node _ twoType ] ->
                                        Ok
                                            { type_ = twoType
                                            , inferences = Dict.empty
                                            , aliases = inference.aliases
                                            }

                                    _ ->
                                        Err []
                    , imports =
                        []
                    }
        }
    }


{-| -}
record :
    List String
    -> Expression
    -> Let (List Expression -> a)
    -> Let a --Let (List Expression)
record fields valueExpr sourceLet =
    -- Note, we can't actually guard the field names against collision here
    -- They have to be the actual field names in the record, duh.
    sourceLet
        |> with
            (Let
                (\index ->
                    ( [ Record fields valueExpr ]
                    , unpackRecord index fields valueExpr
                    )
                )
            )


unpackRecord :
    Compiler.Index
    -> List String
    -> Expression
    -> List Expression
unpackRecord startIndex fields sourceExpression =
    let
        ( index, sourceDetails ) =
            Compiler.toExpressionDetails startIndex sourceExpression
    in
    List.foldl
        (\name gathered ->
            { index = Compiler.next gathered.index
            , fields =
                getFieldReference index name sourceDetails
                    :: gathered.fields
            }
        )
        { index = index
        , fields = []
        }
        fields
        |> .fields


getFieldReference : Compiler.Index -> String -> Compiler.ExpressionDetails -> Expression
getFieldReference index name details =
    case details.annotation of
        Err errs ->
            toRef name details.annotation

        Ok recordDetails ->
            case recordDetails.type_ of
                Annotation.Record recordDefinition ->
                    case getField name recordDefinition of
                        Nothing ->
                            toRef name
                                (Err
                                    [ Compiler.LetFieldNotFound
                                        { desiredField = name }
                                    ]
                                )

                        Just fieldType ->
                            toRef name
                                (Ok
                                    { type_ = fieldType
                                    , inferences = Dict.empty
                                    , aliases = recordDetails.aliases
                                    }
                                )

                Annotation.GenericRecord (Node.Node _ nameOfRecord) (Node.Node _ recordDefinition) ->
                    case getField name recordDefinition of
                        Nothing ->
                            toRef name
                                (Compiler.inferRecordField index
                                    { nameOfRecord = nameOfRecord
                                    , fieldName = name
                                    }
                                )

                        Just fieldType ->
                            toRef name
                                (Ok
                                    { type_ = fieldType
                                    , inferences = Dict.empty
                                    , aliases = recordDetails.aliases
                                    }
                                )

                Annotation.GenericType typename ->
                    toRef name
                        (Compiler.inferRecordField index
                            { nameOfRecord = typename
                            , fieldName = name
                            }
                        )

                _ ->
                    toRef name
                        (Err
                            [ Compiler.LetFieldNotFound
                                { desiredField = name }
                            ]
                        )


getField : String -> Annotation.RecordDefinition -> Maybe Annotation.TypeAnnotation
getField desiredFieldName fields =
    case fields of
        [] ->
            Nothing

        (Node.Node _ ( Node.Node _ fieldName, Node.Node _ fieldType )) :: remain ->
            if fieldName == desiredFieldName then
                Just fieldType

            else
                getField desiredFieldName remain


toRef :
    String
    -> Result (List Compiler.InferenceError) Compiler.Inference
    -> Expression
toRef name annotation =
    Compiler.Expression <|
        \_ ->
            { expression =
                Exp.FunctionOrValue []
                    (Compiler.sanitize name)
            , annotation =
                annotation
            , imports =
                []
            }


{-| -}
toExpression : Let Expression -> Expression
toExpression (Let toScope) =
    Compiler.Expression <|
        \index ->
            let
                ( scope, return ) =
                    toScope index

                ( firstIndex, within ) =
                    Compiler.toExpressionDetails index return

                gathered =
                    List.foldr
                        (\letDecl accum ->
                            case letDecl of
                                Value name valueExpr ->
                                    let
                                        ( new, newExpr ) =
                                            Compiler.toExpressionDetails accum.index valueExpr
                                    in
                                    { index = new
                                    , declarations =
                                        Compiler.nodify
                                            (Exp.LetDestructuring
                                                (Compiler.nodify
                                                    (Pattern.VarPattern name)
                                                )
                                                (Compiler.nodify newExpr.expression)
                                            )
                                            :: accum.declarations
                                    , imports = accum.imports ++ newExpr.imports
                                    }

                                Tuple oneName twoName valueExpr ->
                                    let
                                        ( new, newExpr ) =
                                            Compiler.toExpressionDetails accum.index valueExpr
                                    in
                                    { index = new
                                    , declarations =
                                        Compiler.nodify
                                            (Exp.LetDestructuring
                                                (Compiler.nodify
                                                    (Pattern.TuplePattern
                                                        [ Compiler.nodify (Pattern.VarPattern oneName)
                                                        , Compiler.nodify (Pattern.VarPattern twoName)
                                                        ]
                                                    )
                                                )
                                                (Compiler.nodify newExpr.expression)
                                            )
                                            :: accum.declarations
                                    , imports = accum.imports ++ newExpr.imports
                                    }

                                Record fields valueExpr ->
                                    let
                                        ( new, newExpr ) =
                                            Compiler.toExpressionDetails accum.index valueExpr
                                    in
                                    { index = new
                                    , declarations =
                                        Compiler.nodify
                                            (Exp.LetDestructuring
                                                (Compiler.nodify
                                                    (Pattern.RecordPattern
                                                        (List.map Compiler.nodify
                                                            fields
                                                        )
                                                    )
                                                )
                                                (Compiler.nodify newExpr.expression)
                                            )
                                            :: accum.declarations
                                    , imports = accum.imports ++ newExpr.imports
                                    }
                        )
                        { index = firstIndex
                        , declarations = []
                        , imports = []
                        }
                        scope
            in
            { expression =
                Exp.LetExpression
                    { declarations = gathered.declarations
                    , expression = Compiler.nodify within.expression
                    }
            , imports = gathered.imports
            , annotation =
                within.annotation
            }
