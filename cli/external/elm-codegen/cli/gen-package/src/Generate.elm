module Generate exposing (main)

{-| -}

import DocsFromSource
import Elm
import Elm.Annotation as Annotation
import Elm.Case
import Elm.Docs
import Elm.Gen
import Elm.Syntax.TypeAnnotation
import Elm.Type
import Gen.Elm
import Gen.Elm.Annotation as GenType
import Gen.Elm.Case
import Gen.List
import Internal.Compiler as Compiler
import Internal.Write as Write
import Json.Decode as Json


main : Program Json.Value () ()
main =
    Platform.worker
        { init =
            \json ->
                case Json.decodeValue flagsDecoder json of
                    Err err ->
                        ( ()
                        , Elm.Gen.error
                            { title = "Invalid docs"
                            , description =
                                Json.errorToString err
                            }
                        )

                    Ok (Docs docs) ->
                        ( ()
                        , Elm.Gen.files
                            (List.map moduleToFile docs)
                        )

                    Ok (ElmSource srcs) ->
                        case parseSources srcs [] of
                            Ok docs ->
                                ( ()
                                , Elm.Gen.files
                                    (List.map moduleToFile docs)
                                )

                            Err err ->
                                ( ()
                                , Elm.Gen.error
                                    { title = "Error generating docs"
                                    , description =
                                        err
                                    }
                                )
        , update =
            \msg model ->
                ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


parseSources : List String -> List Elm.Docs.Module -> Result String (List Elm.Docs.Module)
parseSources srcs parsed =
    case srcs of
        [] ->
            Ok parsed

        top :: remain ->
            case DocsFromSource.fromSource top of
                Err err ->
                    Err err

                Ok topParsed ->
                    parseSources remain (topParsed :: parsed)


type Flags
    = Docs (List Elm.Docs.Module)
    | ElmSource (List String)


flagsDecoder : Json.Decoder Flags
flagsDecoder =
    Json.oneOf
        [ Json.field "docs"
            (Json.list Elm.Docs.decoder)
            |> Json.map Docs
        , Json.field "elmSource" (Json.list Json.string)
            |> Json.map ElmSource
        ]


moduleToFile : Elm.Docs.Module -> Elm.File
moduleToFile docs =
    let
        blocks =
            Elm.Docs.toBlocks docs

        sourceModName =
            String.split "." docs.name

        modName =
            "Gen" :: sourceModName

        modNameBlock =
            Elm.declaration "moduleName_"
                (Elm.list (List.map Elm.string sourceModName))
                |> Elm.withDocumentation " The name of this module. "
                |> Elm.expose
    in
    Elm.fileWith modName
        { docs =
            List.map Elm.docs
        , aliases =
            [ ( [ "Elm", "Annotation" ], "Type" )
            ]
        }
        (modNameBlock
            :: List.concatMap (generateBlocks sourceModName) blocks
            ++ List.filterMap identity
                [ record "annotation_"
                    blocks
                    (annotation sourceModName)
                , recordWithFieldList "make_"
                    blocks
                    (typeCreation sourceModName)
                , record "caseOf_"
                    blocks
                    (caseOf sourceModName)
                , record "call_"
                    blocks
                    (blockToCall sourceModName)
                , record "values_"
                    blocks
                    (blockToIdField sourceModName)
                ]
        )


elmAnnotation : List String
elmAnnotation =
    [ "Elm", "Annotation" ]


annotationType : Annotation.Annotation
annotationType =
    Annotation.named elmAnnotation "Annotation"


elm : List String
elm =
    [ "Elm" ]


local : List String
local =
    []


thisModuleName : Elm.Expression
thisModuleName =
    Elm.value
        { importFrom = local
        , name = "moduleName_"
        , annotation =
            Just (Annotation.list Annotation.string)
        }


valueWith : List String -> String -> Elm.Type.Type -> Elm.Expression
valueWith thisModule name ann =
    Gen.Elm.value
        { importFrom = thisModule
        , name = name
        , annotation =
            typeToExpression thisModule ann
                |> Just
                |> Elm.maybe
        }


apply : Elm.Expression -> List Elm.Expression -> Elm.Expression
apply fn args =
    Gen.Elm.apply fn args


expressionType : Annotation.Annotation
expressionType =
    Annotation.named elm "Expression"


blockToCall : List String -> Elm.Docs.Block -> Maybe Elm.Field
blockToCall thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            Nothing

        Elm.Docs.UnionBlock union ->
            Nothing

        Elm.Docs.AliasBlock alias ->
            Nothing

        Elm.Docs.ValueBlock value ->
            case value.tipe of
                Elm.Type.Lambda one two ->
                    let
                        captured =
                            captureFunction value.name
                                value.tipe
                                { arguments =
                                    []
                                , unpackers = []
                                }

                        arguments =
                            List.drop 1 captured.arguments
                                |> List.foldl
                                    (\( name, _ ) args ->
                                        ( name, Just expressionType ) :: args
                                    )
                                    []

                        vals =
                            List.drop 1 captured.arguments
                                |> List.foldl
                                    (\( name, _ ) args ->
                                        Elm.value
                                            { importFrom = []
                                            , name = name
                                            , annotation =
                                                Just expressionType
                                            }
                                            :: args
                                    )
                                    []
                    in
                    Elm.function arguments
                        (Gen.Elm.apply
                            (Gen.Elm.value
                                { importFrom = thisModule
                                , name = value.name
                                , annotation =
                                    typeToExpression thisModule value.tipe
                                        |> Just
                                        |> Elm.maybe
                                }
                            )
                        )
                        |> Elm.field value.name
                        |> Just

                _ ->
                    Nothing

        Elm.Docs.BinopBlock binop ->
            Nothing

        Elm.Docs.UnknownBlock str ->
            Nothing


blockToIdField : List String -> Elm.Docs.Block -> Maybe Elm.Field
blockToIdField thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            Nothing

        Elm.Docs.UnionBlock union ->
            Nothing

        Elm.Docs.AliasBlock alias ->
            Nothing

        Elm.Docs.ValueBlock value ->
            Just
                (Elm.field
                    value.name
                    (valueWith thisModule
                        value.name
                        value.tipe
                    )
                )

        Elm.Docs.BinopBlock binop ->
            Nothing

        Elm.Docs.UnknownBlock str ->
            Nothing


{-| -}
block2Case : List String -> Elm.Docs.Union -> Maybe Elm.Expression
block2Case thisModule union =
    case union.tags of
        [] ->
            -- This type has not been exposed and can't be constructed
            Nothing

        _ ->
            Just
                (Elm.fn2 "expresssion"
                    "tags"
                    (\express tagRecord ->
                        Gen.Elm.Case.custom express
                            (List.filterMap
                                (\( tagname, subtypes ) ->
                                    let
                                        moduleName =
                                            Elm.list (List.map Elm.string thisModule)

                                        tagString =
                                            Elm.string tagname
                                    in
                                    case subtypes of
                                        [] ->
                                            Gen.Elm.Case.call_.branch0
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        [ _ ] ->
                                            Gen.Elm.Case.call_.branch1
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        [ _, _ ] ->
                                            Gen.Elm.Case.call_.branch2
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        [ _, _, _ ] ->
                                            Gen.Elm.Case.call_.branch3
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        [ _, _, _, _ ] ->
                                            Gen.Elm.Case.call_.branch4
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        [ _, _, _, _, _ ] ->
                                            Gen.Elm.Case.call_.branch5
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        [ _, _, _, _, _, _ ] ->
                                            Gen.Elm.Case.call_.branch6
                                                moduleName
                                                tagString
                                                (Elm.get tagname tagRecord)
                                                |> Just

                                        _ ->
                                            Nothing
                                )
                                union.tags
                            )
                    )
                )


block2Maker : List String -> Elm.Docs.Block -> Maybe Elm.Expression
block2Maker thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            Nothing

        Elm.Docs.UnionBlock union ->
            case union.tags of
                [] ->
                    -- This type has not been exposed and can't be constructed
                    Nothing

                _ ->
                    Just
                        (Elm.record
                            (List.map
                                (\( name, tags ) ->
                                    case tags of
                                        [] ->
                                            Elm.field name
                                                (valueWith thisModule
                                                    name
                                                    (Elm.Type.Type union.name
                                                        (List.map Elm.Type.Var union.args)
                                                    )
                                                )

                                        _ ->
                                            Elm.field name
                                                (Elm.function
                                                    (List.indexedMap
                                                        (\i tag ->
                                                            ( "ar" ++ String.fromInt i
                                                            , Just expressionType
                                                            )
                                                        )
                                                        tags
                                                    )
                                                    (\vars ->
                                                        apply
                                                            (valueWith thisModule
                                                                name
                                                                (Elm.Type.Type union.name
                                                                    (List.map Elm.Type.Var union.args)
                                                                )
                                                            )
                                                            vars
                                                    )
                                                )
                                )
                                union.tags
                            )
                        )

        Elm.Docs.AliasBlock { name, tipe } ->
            case tipe of
                Elm.Type.Record fields Nothing ->
                    let
                        lambdaArgType =
                            fields
                                |> List.map (\( fieldName, _ ) -> ( fieldName, expressionType ))
                                |> Annotation.record

                        lambdaValue val =
                            let
                                arg =
                                    val
                                        |> Elm.withType lambdaArgType
                            in
                            fields
                                |> List.map
                                    (\( fieldName, _ ) ->
                                        Gen.Elm.field fieldName
                                            (Elm.get fieldName arg)
                                    )
                                |> Gen.Elm.record
                    in
                    Elm.fn "arg" lambdaValue
                        |> Just

                _ ->
                    Nothing

        Elm.Docs.ValueBlock value ->
            Nothing

        Elm.Docs.BinopBlock binop ->
            Nothing

        Elm.Docs.UnknownBlock str ->
            Nothing


record : String -> List Elm.Docs.Block -> (Elm.Docs.Block -> Maybe Elm.Field) -> Maybe Elm.Declaration
record recordName blocks makeField =
    let
        fields =
            blocks
                |> List.filterMap makeField
    in
    case fields of
        [] ->
            Nothing

        _ ->
            fields
                |> Elm.record
                |> Elm.declaration recordName
                |> Elm.expose
                |> Just


recordWithFieldList : String -> List Elm.Docs.Block -> (Elm.Docs.Block -> List Elm.Field) -> Maybe Elm.Declaration
recordWithFieldList recordName blocks makeField =
    let
        fields =
            blocks
                |> List.concatMap makeField
    in
    case fields of
        [] ->
            Nothing

        _ ->
            fields
                |> Elm.record
                |> Elm.declaration recordName
                |> Elm.expose
                |> Just


caseOf : List String -> Elm.Docs.Block -> Maybe Elm.Field
caseOf thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            Nothing

        Elm.Docs.UnionBlock union ->
            Maybe.map
                (Elm.field union.name)
                (block2Case thisModule union)

        Elm.Docs.AliasBlock alias ->
            Nothing

        Elm.Docs.ValueBlock value ->
            Nothing

        Elm.Docs.BinopBlock binop ->
            Nothing

        Elm.Docs.UnknownBlock str ->
            Nothing


annotation : List String -> Elm.Docs.Block -> Maybe Elm.Field
annotation thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            Nothing

        Elm.Docs.UnionBlock union ->
            Elm.field union.name
                (annotationNamed union.name union.args)
                |> Just

        Elm.Docs.AliasBlock alias ->
            Elm.field alias.name
                (aliasNamed alias)
                |> Just

        Elm.Docs.ValueBlock value ->
            Nothing

        Elm.Docs.BinopBlock binop ->
            Nothing

        Elm.Docs.UnknownBlock str ->
            Nothing


annotationNamed : String -> List String -> Elm.Expression
annotationNamed name tags =
    case tags of
        [] ->
            localType name []

        nonEmpty ->
            Elm.function
                (List.indexedMap
                    (\i arg ->
                        ( "arg" ++ String.fromInt i
                        , Just (Annotation.named elmAnnotation "Annotation")
                        )
                    )
                    nonEmpty
                )
                (\args ->
                    localType name args
                )


localType : String -> List Elm.Expression -> Elm.Expression
localType name args =
    Elm.apply
        (Elm.value
            { importFrom = [ "Elm", "Annotation" ]
            , name = "namedWith"
            , annotation =
                Just
                    (Annotation.function
                        [ Annotation.list Annotation.string
                        , Annotation.string
                        , Annotation.list
                            (Annotation.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                        ]
                        (Annotation.namedWith [ "Elm", "Annotation" ] "Annotation" [])
                    )
            }
        )
        [ thisModuleName
        , Elm.string name
        , Elm.list args
        ]


aliasNamed : Elm.Docs.Alias -> Elm.Expression
aliasNamed docAlias =
    case docAlias.args of
        [] ->
            GenType.call_.alias
                thisModuleName
                (Elm.string docAlias.name)
                (Elm.list [])
                (typeToExpression []
                    docAlias.tipe
                )

        nonEmpty ->
            Elm.function
                (List.indexedMap
                    (\i arg ->
                        ( "arg" ++ String.fromInt i
                        , Just (Annotation.named elmAnnotation "Annotation")
                        )
                    )
                    nonEmpty
                )
                (\args ->
                    GenType.call_.alias
                        thisModuleName
                        (Elm.string docAlias.name)
                        (Elm.list args)
                        (typeToExpression [] docAlias.tipe)
                )


typeCreation : List String -> Elm.Docs.Block -> List Elm.Field
typeCreation thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            []

        Elm.Docs.UnionBlock union ->
            case union.tags of
                [] ->
                    -- This type has not been exposed and can't be constructed
                    []

                _ ->
                    List.map
                        (\( name, tags ) ->
                            case tags of
                                [] ->
                                    Elm.field name
                                        (valueWith thisModule
                                            name
                                            (Elm.Type.Type union.name
                                                (List.map Elm.Type.Var union.args)
                                            )
                                        )

                                _ ->
                                    Elm.field name
                                        (Elm.function
                                            (List.indexedMap
                                                (\i tag ->
                                                    ( "ar" ++ String.fromInt i
                                                    , Just expressionType
                                                    )
                                                )
                                                tags
                                            )
                                            (\vars ->
                                                apply
                                                    (valueWith thisModule
                                                        name
                                                        (Elm.Type.Type union.name
                                                            (List.map Elm.Type.Var union.args)
                                                        )
                                                    )
                                                    vars
                                            )
                                        )
                        )
                        union.tags

        Elm.Docs.AliasBlock alias ->
            case alias.tipe of
                Elm.Type.Record fields Nothing ->
                    let
                        lambdaArgType =
                            fields
                                |> List.map (\( fieldName, _ ) -> ( fieldName, expressionType ))
                                |> Annotation.record
                    in
                    [ Elm.fn "arg"
                        (\val ->
                            let
                                arg =
                                    val
                                        |> Elm.withType lambdaArgType
                            in
                            fields
                                |> List.map
                                    (\( fieldName, _ ) ->
                                        Gen.Elm.field fieldName
                                            (Elm.get fieldName arg)
                                    )
                                |> Gen.Elm.record
                                |> Gen.Elm.withAlias thisModule
                                    alias.name
                                    (List.map GenType.var alias.args)
                        )
                        |> Elm.field alias.name
                    ]

                _ ->
                    []

        Elm.Docs.ValueBlock value ->
            []

        Elm.Docs.BinopBlock binop ->
            []

        Elm.Docs.UnknownBlock str ->
            []


generateBlocks : List String -> Elm.Docs.Block -> List Elm.Declaration
generateBlocks thisModule block =
    case block of
        Elm.Docs.MarkdownBlock str ->
            []

        Elm.Docs.UnionBlock union ->
            []

        Elm.Docs.AliasBlock alias ->
            []

        Elm.Docs.ValueBlock value ->
            case value.tipe of
                Elm.Type.Lambda one two ->
                    let
                        captured =
                            captureFunction value.name
                                value.tipe
                                { arguments =
                                    []
                                , unpackers =
                                    []
                                }
                    in
                    [ Elm.function
                        (List.reverse (List.drop 1 captured.arguments))
                        (\vars ->
                            Gen.Elm.apply
                                (Gen.Elm.value
                                    { importFrom = thisModule
                                    , name = value.name
                                    , annotation =
                                        typeToExpression thisModule value.tipe
                                            |> Just
                                            |> Elm.maybe
                                    }
                                )
                                (List.map2
                                    (<|)
                                    (List.reverse (List.drop 1 captured.unpackers))
                                    vars
                                )
                        )
                        |> Elm.declaration value.name
                        |> Elm.withDocumentation (value.name ++ ": " ++ typeToString value.tipe)
                        |> Elm.withDocumentation value.comment
                        |> Elm.expose
                    ]

                _ ->
                    [ Elm.declaration value.name
                        (valueWith thisModule
                            value.name
                            value.tipe
                            |> Elm.withType expressionType
                        )
                        |> Elm.withDocumentation (value.name ++ ": " ++ typeToString value.tipe)
                        |> Elm.withDocumentation value.comment
                        |> Elm.expose
                    ]

        Elm.Docs.BinopBlock binop ->
            --All binops are defined in the top level `Elm` library
            []

        Elm.Docs.UnknownBlock str ->
            []


{-| Ultimately we want to capture

    { arguments =
        [ ( expressionType, Elm.Pattern.var "one" )
        , ( expressionType, Elm.Pattern.var "two" )
        , ( expressionType, Elm.Pattern.car "three" )
        ]
    , body =
        Elm.apply
            (valueWith
                (Elm.apply (Elm.valueFrom elm "moduleName")
                    [ Elm.list (List.map Elm.string mod)
                    ]
                )
                (Elm.string value.name)
            )
            [ Elm.value "one"
            , Elm.value "two"
            , Elm.value "three"
            ]
    }

-}
captureFunction :
    String
    -> Elm.Type.Type
    ->
        { arguments : List ( String, Maybe Annotation.Annotation )
        , unpackers : List (Elm.Expression -> Elm.Expression)
        }
    ->
        { arguments : List ( String, Maybe Annotation.Annotation )
        , unpackers : List (Elm.Expression -> Elm.Expression)
        }
captureFunction baseName tipe captured =
    case tipe of
        Elm.Type.Lambda one two ->
            let
                unpacked =
                    unpackArg one
            in
            captureFunction baseName
                two
                { arguments = ( "arg", Just unpacked.annotation ) :: captured.arguments
                , unpackers = unpacked.unpacker :: captured.unpackers
                }

        _ ->
            let
                unpacked =
                    unpackArg tipe
            in
            { arguments = ( "arg", Just unpacked.annotation ) :: captured.arguments
            , unpackers = unpacked.unpacker :: captured.unpackers
            }


unpackArgForLambdas :
    Elm.Type.Type
    ->
        { annotation : Annotation.Annotation
        , unpacker : Elm.Expression -> Elm.Expression
        }
unpackArgForLambdas tipe =
    case tipe of
        Elm.Type.Lambda one two ->
            let
                unpacked =
                    unpackArgForLambdas two
            in
            { annotation =
                Annotation.function [ expressionType ]
                    unpacked.annotation
            , unpacker =
                \renderer ->
                    Gen.Elm.functionReduced
                        "unpack"
                        (\val ->
                            let
                                full =
                                    val
                                        |> Elm.withType (typeToGeneratedAnnotationExpression one)
                            in
                            unpackFunction "unpack"
                                (Elm.apply renderer [ full ])
                                two
                        )
            }

        _ ->
            { annotation = expressionType
            , unpacker = identity
            }


unpackArg :
    Elm.Type.Type
    ->
        { annotation : Annotation.Annotation
        , unpacker : Elm.Expression -> Elm.Expression
        }
unpackArg tipe =
    case tipe of
        Elm.Type.Lambda one two ->
            let
                unpacked =
                    unpackArgForLambdas two
            in
            { annotation =
                Annotation.function
                    [ expressionType
                    ]
                    unpacked.annotation
            , unpacker =
                \value ->
                    Gen.Elm.functionReduced
                        "unpack"
                        (\val ->
                            unpacked.unpacker
                                (Elm.apply value [ val ])
                        )
            }

        Elm.Type.Type "List.List" [ inner ] ->
            if needsUnpacking inner then
                let
                    unpacked =
                        unpackArg inner
                in
                { annotation =
                    Annotation.list
                        unpacked.annotation
                , unpacker =
                    \value ->
                        Gen.List.call_.map
                            (Elm.functionReduced "unpack"
                                unpacked.unpacker
                            )
                            value
                            |> Gen.Elm.call_.list
                }

            else
                { annotation =
                    Annotation.list
                        expressionType
                , unpacker =
                    Gen.Elm.call_.list
                }

        Elm.Type.Type "Basics.Bool" [] ->
            { annotation = Annotation.bool
            , unpacker = Gen.Elm.call_.bool
            }

        Elm.Type.Type "Basics.Float" [] ->
            { annotation = Annotation.float
            , unpacker = Gen.Elm.call_.float
            }

        Elm.Type.Type "Basics.Int" [] ->
            { annotation = Annotation.int
            , unpacker = Gen.Elm.call_.int
            }

        Elm.Type.Type "String.String" [] ->
            { annotation = Annotation.string
            , unpacker = Gen.Elm.call_.string
            }

        Elm.Type.Type "Char.Char" [] ->
            { annotation = Annotation.char
            , unpacker = Gen.Elm.call_.char
            }

        Elm.Type.Type modAndName typeVars ->
            { annotation = expressionType
            , unpacker = identity
            }

        Elm.Type.Record fields Nothing ->
            let
                unpackedFields =
                    List.map
                        (Tuple.mapSecond unpackArg)
                        fields
            in
            { annotation =
                List.map (Tuple.mapSecond .annotation) unpackedFields
                    |> Annotation.record
            , unpacker =
                \rec ->
                    List.map
                        (\( fieldName, unpacked ) ->
                            Gen.Elm.field fieldName
                                (unpacked.unpacker (Elm.get fieldName rec))
                        )
                        unpackedFields
                        |> Gen.Elm.record
            }

        Elm.Type.Record fields (Just genName) ->
            let
                unpackedFields =
                    List.map
                        (Tuple.mapSecond unpackArg)
                        fields
            in
            { annotation =
                List.map (Tuple.mapSecond .annotation) unpackedFields
                    |> Annotation.extensible genName
            , unpacker =
                \rec ->
                    List.map
                        (\( fieldName, unpacked ) ->
                            Gen.Elm.field fieldName
                                (unpacked.unpacker (Elm.get fieldName rec))
                        )
                        unpackedFields
                        |> Gen.Elm.record
            }

        Elm.Type.Tuple tuples ->
            { annotation = expressionType
            , unpacker = identity
            }

        Elm.Type.Var name ->
            { annotation = expressionType
            , unpacker = identity
            }


needsUnpacking : Elm.Type.Type -> Bool
needsUnpacking tipe =
    case tipe of
        Elm.Type.Type "List.List" [ _ ] ->
            True

        Elm.Type.Type "Basics.Bool" [] ->
            True

        Elm.Type.Type "Basics.Float" [] ->
            True

        Elm.Type.Type "Basics.Int" [] ->
            True

        Elm.Type.Type "String.String" [] ->
            True

        Elm.Type.Type "Char.Char" [] ->
            True

        Elm.Type.Record _ _ ->
            True

        _ ->
            False


getArity : Int -> Elm.Type.Type -> Int
getArity i tipe =
    case tipe of
        Elm.Type.Lambda one two ->
            getArity (i + 1) two

        _ ->
            i


functionArgTypes : Elm.Type.Type -> List Elm.Type.Type -> { args : List Elm.Type.Type, return : Elm.Type.Type }
functionArgTypes fnType args =
    case fnType of
        Elm.Type.Lambda one two ->
            functionArgTypes two (one :: args)

        _ ->
            { args = List.reverse args
            , return = fnType
            }


unpackFunction : String -> Elm.Expression -> Elm.Type.Type -> Elm.Expression
unpackFunction baseName renderer tipe =
    case tipe of
        Elm.Type.Lambda one two ->
            Gen.Elm.functionReduced
                baseName
                (\val ->
                    let
                        full =
                            val
                                |> Elm.withType (typeToGeneratedAnnotationExpression one)
                    in
                    unpackFunction baseName
                        (Elm.apply renderer [ full ])
                        two
                )

        _ ->
            renderer


{-|

    type Type
        = Var String
        | Lambda Type Type
        | Tuple (List Type)
        | Type String (List Type)
        | Record (List ( String, Type )) (Maybe String)


    This is the *generated* type annotation.

    So, normally, the type for a Type "String" []
    would be a `String`

    This function would list that as an `Expression`

-}
typeToGeneratedAnnotation : Elm.Type.Type -> Annotation.Annotation
typeToGeneratedAnnotation elmType =
    case elmType of
        Elm.Type.Var string ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Lambda one two ->
            Annotation.function
                [ Annotation.namedWith [ "Elm" ] "Expression" []
                ]
                (typeToGeneratedAnnotationExpression two)

        Elm.Type.Tuple types ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Type "List.List" [ inner ] ->
            Annotation.list (typeToGeneratedAnnotation inner)

        Elm.Type.Type name types ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Record fields maybeExtensible ->
            case maybeExtensible of
                Nothing ->
                    Annotation.record (List.map (Tuple.mapSecond typeToGeneratedAnnotation) fields)

                Just base ->
                    Annotation.extensible base (List.map (Tuple.mapSecond typeToGeneratedAnnotation) fields)


typeToGeneratedAnnotationExpression : Elm.Type.Type -> Annotation.Annotation
typeToGeneratedAnnotationExpression elmType =
    case elmType of
        Elm.Type.Var string ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Lambda one two ->
            Annotation.function
                [ typeToGeneratedAnnotationExpression one ]
                (typeToGeneratedAnnotationExpression two)

        Elm.Type.Tuple types ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Type "List.List" [ inner ] ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Type name types ->
            Annotation.namedWith [ "Elm" ] "Expression" []

        Elm.Type.Record fields maybeExtensible ->
            Annotation.namedWith [ "Elm" ] "Expression" []


chompLambdas : List String -> List Elm.Expression -> Elm.Type.Type -> Elm.Expression
chompLambdas thisModule exps tipe =
    case tipe of
        Elm.Type.Lambda one two ->
            chompLambdas thisModule
                (typeToExpression thisModule one :: exps)
                two

        _ ->
            GenType.function
                (List.reverse exps)
                (typeToExpression thisModule tipe)


typeToExpression : List String -> Elm.Type.Type -> Elm.Expression
typeToExpression thisModule elmType =
    case elmType of
        Elm.Type.Var string ->
            GenType.var string

        Elm.Type.Lambda one two ->
            chompLambdas thisModule
                [ typeToExpression thisModule one
                ]
                two

        Elm.Type.Tuple types ->
            case types of
                [] ->
                    GenType.unit

                [ one, two ] ->
                    GenType.tuple
                        (typeToExpression thisModule one)
                        (typeToExpression thisModule two)

                [ one, two, three ] ->
                    GenType.triple
                        (typeToExpression thisModule one)
                        (typeToExpression thisModule two)
                        (typeToExpression thisModule three)

                _ ->
                    -- this should never happen :/
                    Elm.value
                        { importFrom = elmAnnotation
                        , name = "unit"
                        , annotation = Just annotationType
                        }

        Elm.Type.Type name types ->
            namedWithType thisModule name types

        Elm.Type.Record fields maybeExtensible ->
            case maybeExtensible of
                Nothing ->
                    GenType.record
                        (List.map
                            (\( fieldName, fieldType ) ->
                                Elm.tuple
                                    (Elm.string fieldName)
                                    (typeToExpression thisModule fieldType)
                            )
                            fields
                        )

                Just base ->
                    GenType.extensible
                        base
                        (List.map
                            (\( fieldName, fieldType ) ->
                                Elm.tuple
                                    (Elm.string fieldName)
                                    (typeToExpression thisModule fieldType)
                            )
                            fields
                        )


namedWithType : List String -> String -> List Elm.Type.Type -> Elm.Expression
namedWithType thisModule name types =
    let
        frags =
            String.split "." name
    in
    case frags of
        [ "List", "List" ] ->
            case types of
                [ inner ] ->
                    GenType.list (typeToExpression thisModule inner)

                _ ->
                    GenType.unit

        [ "Maybe", "Maybe" ] ->
            case types of
                [ inner ] ->
                    GenType.maybe (typeToExpression thisModule inner)

                _ ->
                    GenType.unit

        [ "Basics", "Int" ] ->
            GenType.int

        [ "Basics", "Float" ] ->
            GenType.float

        [ "Basics", "Bool" ] ->
            GenType.bool

        [ "String", "String" ] ->
            GenType.string

        [ "Char", "Char" ] ->
            GenType.char

        _ ->
            let
                fragsLength =
                    List.length frags

                typeName =
                    List.drop (fragsLength - 1) frags
                        |> List.head
                        |> Maybe.withDefault name
            in
            GenType.namedWith
                (List.take (fragsLength - 1) frags)
                typeName
                (List.map (typeToExpression thisModule) types)


typeToString : Elm.Type.Type -> String
typeToString type_ =
    let
        lines =
            docTypeToAnnotation type_
                |> Write.writeAnnotation
                |> String.lines
    in
    case lines of
        [] ->
            ""

        [ one ] ->
            one

        many ->
            "\n    " ++ String.join "\n    " many


docTypeToAnnotation : Elm.Type.Type -> Elm.Syntax.TypeAnnotation.TypeAnnotation
docTypeToAnnotation tipe =
    case tipe of
        Elm.Type.Var var ->
            Elm.Syntax.TypeAnnotation.GenericType var

        Elm.Type.Type typeName inner ->
            let
                modName =
                    case List.reverse (String.split "." typeName) of
                        [] ->
                            Compiler.nodify ( [], "()" )

                        [ "Int", "Basics" ] ->
                            Compiler.nodify ( [], "Int" )

                        [ "Float", "Basics" ] ->
                            Compiler.nodify ( [], "Float" )

                        [ "Bool", "Basics" ] ->
                            Compiler.nodify ( [], "Bool" )

                        [ "String", "String" ] ->
                            Compiler.nodify ( [], "String" )

                        [ "List", "List" ] ->
                            Compiler.nodify ( [], "List" )

                        [ "Maybe", "Maybe" ] ->
                            Compiler.nodify ( [], "Maybe" )

                        top :: tail ->
                            Compiler.nodify ( List.reverse tail, top )
            in
            Elm.Syntax.TypeAnnotation.Typed
                modName
                (List.map (docTypeToAnnotation >> Compiler.nodify) inner)

        Elm.Type.Tuple [] ->
            Elm.Syntax.TypeAnnotation.Unit

        Elm.Type.Tuple inner ->
            Elm.Syntax.TypeAnnotation.Tupled
                (List.map (docTypeToAnnotation >> Compiler.nodify) inner)

        Elm.Type.Record fields Nothing ->
            Elm.Syntax.TypeAnnotation.Record
                (List.map
                    (\( name, fieldType ) ->
                        Compiler.nodify
                            ( Compiler.nodify name
                            , Compiler.nodify
                                (docTypeToAnnotation fieldType)
                            )
                    )
                    fields
                )

        Elm.Type.Record fields (Just recordName) ->
            Elm.Syntax.TypeAnnotation.GenericRecord (Compiler.nodify recordName)
                (Compiler.nodify
                    (List.map
                        (\( name, fieldType ) ->
                            Compiler.nodify
                                ( Compiler.nodify name
                                , Compiler.nodify
                                    (docTypeToAnnotation fieldType)
                                )
                        )
                        fields
                    )
                )

        Elm.Type.Lambda one two ->
            Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation
                (Compiler.nodify (docTypeToAnnotation one))
                (Compiler.nodify (docTypeToAnnotation two))
