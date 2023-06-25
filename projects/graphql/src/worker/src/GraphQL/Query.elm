module GraphQL.Query exposing (generate)

import CodeGen
import CodeGen.Annotation
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import Set exposing (Set)
import String.Extra


type alias File =
    { filepath : List String
    , contents : String
    }


generate : { schema : Schema, document : Document } -> File
generate ({ schema, document } as options) =
    { filepath =
        [ "GraphQL"
        , "Queries"
        , Document.toName document ++ ".elm"
        ]
    , contents =
        CodeGen.Module.toString (toModule options)
    }


type alias Options =
    { schema : Schema
    , document : Document
    }


toModule : Options -> CodeGen.Module
toModule ({ schema, document } as options) =
    let
        dataTypeAlias : CodeGen.Declaration
        dataTypeAlias =
            CodeGen.Declaration.typeAlias
                { name = "Data"
                , annotation = toDataAnnotation options
                }

        nestedTypeAliases : List CodeGen.Declaration
        nestedTypeAliases =
            Document.getNestedFields schema document
                |> List.foldl toNestedTypeAlias
                    { existingNames = Set.empty
                    , declarations = []
                    }
                |> .declarations

        toNestedTypeAlias :
            { parentTypeName : String
            , fieldSelection : Document.FieldSelection
            }
            -> { existingNames : Set String, declarations : List CodeGen.Declaration }
            -> { existingNames : Set String, declarations : List CodeGen.Declaration }
        toNestedTypeAlias { parentTypeName, fieldSelection } ({ existingNames, declarations } as data) =
            let
                parentObjectType : Maybe Schema.ObjectType
                parentObjectType =
                    Schema.findTypeWithName
                        parentTypeName
                        schema
                        |> Maybe.andThen Schema.toObjectType

                maybeField : Maybe Schema.Field
                maybeField =
                    parentObjectType
                        |> Maybe.andThen (Schema.findFieldWithName fieldSelection.name)

                maybeObjectType : Maybe Schema.ObjectType
                maybeObjectType =
                    maybeField
                        |> Maybe.andThen
                            (\field ->
                                Schema.findTypeWithName
                                    (Schema.toTypeRefName field.type_)
                                    schema
                            )
                        |> Maybe.andThen Schema.toObjectType
            in
            case ( maybeField, maybeObjectType ) of
                ( Just field, _ ) ->
                    let
                        typeAliasName : String
                        typeAliasName =
                            toNameThatWontClash
                                { field = field
                                , existingNames = existingNames
                                }
                                NameBasedOffOfSchemaType
                    in
                    { existingNames = Set.insert typeAliasName existingNames
                    , declarations =
                        declarations
                            ++ [ CodeGen.Declaration.typeAlias
                                    { name = typeAliasName
                                    , annotation =
                                        fieldSelection.selections
                                            |> List.filterMap Document.toFieldSelection
                                            |> List.map
                                                (\innerField ->
                                                    ( innerField.alias
                                                        |> Maybe.withDefault innerField.name
                                                    , Schema.findFieldForType
                                                        { typeName = Schema.toTypeRefName field.type_
                                                        , fieldName = innerField.name
                                                        }
                                                        schema
                                                        |> Maybe.map toTypeRefAnnotation
                                                        |> Maybe.withDefault (CodeGen.Annotation.type_ "HALP")
                                                    )
                                                )
                                            |> CodeGen.Annotation.multilineRecord
                                    }
                               ]
                    }

                _ ->
                    { data
                        | declarations =
                            declarations
                                ++ [ CodeGen.Declaration.comment
                                        [ "🚨 ERROR WITH @elm-land/graphql"
                                        , "You're seeing this message because Elm Land failed"
                                        , "to generate a type alias for you. Please report this"
                                        , "issue at https://join.elm.land"
                                        ]
                                   ]
                    }

        newFunction : CodeGen.Declaration
        newFunction =
            let
                expression : CodeGen.Expression
                expression =
                    CodeGen.Expression.multilineFunction
                        { name = "GraphQL.Operation.new"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "name", CodeGen.Expression.string (Document.toName document) )
                                , ( "query"
                                  , CodeGen.Expression.value
                                        ("\"\"\"\n${contents}\n  \"\"\""
                                            |> String.replace "${contents}"
                                                (Document.toContents document
                                                    |> String.replace "\"\"\"" "\\\"\\\"\\\""
                                                    |> String.split "\n"
                                                    |> String.join "\n    "
                                                    |> String.append "    "
                                                )
                                        )
                                  )
                                , ( "variables", CodeGen.Expression.list [] )
                                , ( "decoder", CodeGen.Expression.value "decoder" )
                                ]
                            ]
                        }
            in
            CodeGen.Declaration.function
                { name = "new"
                , annotation = CodeGen.Annotation.type_ "GraphQL.Operation.Operation Data"
                , arguments = []
                , expression = expression
                }

        decoderFunction : CodeGen.Declaration
        decoderFunction =
            let
                expression : CodeGen.Expression
                expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.value "GraphQL.Decode.object Data"
                        , CodeGen.Expression.multilineFunction
                            { name = "GraphQL.Decode.field"
                            , arguments =
                                [ CodeGen.Expression.multilineRecord
                                    [ ( "name", CodeGen.Expression.string "hello" )
                                    , ( "decoder", CodeGen.Expression.value "GraphQL.Decode.string" )
                                    ]
                                ]
                            }
                        ]
            in
            CodeGen.Declaration.function
                { name = "decoder"
                , annotation = CodeGen.Annotation.type_ "GraphQL.Decode.Decoder Data"
                , arguments = []
                , expression = expression
                }
    in
    CodeGen.Module.new
        { name =
            [ "GraphQL"
            , "Queries"
            , Document.toName document
            ]
        , exposing_ =
            [ "Data"
            , "new"
            ]
        , imports =
            [ CodeGen.Import.new [ "GraphQL", "Decode" ]
            , CodeGen.Import.new [ "GraphQL", "Operation" ]
            ]
        , declarations =
            List.concat
                [ [ CodeGen.Declaration.comment [ "DATA" ]
                  , dataTypeAlias
                  ]
                , nestedTypeAliases
                , [ newFunction
                  , decoderFunction
                  ]
                ]
        }


type NameAttempt
    = NameBasedOffOfSchemaType
    | NameBasedOffOfFieldPlusSchemaType
    | NameBasedOffOfFieldPlusSchemaTypePlus Int


toNameThatWontClash : { field : Schema.Field, existingNames : Set String } -> NameAttempt -> String
toNameThatWontClash ({ field, existingNames } as options) nameAttempt =
    case nameAttempt of
        NameBasedOffOfSchemaType ->
            let
                name : String
                name =
                    Schema.toTypeRefName field.type_
            in
            if Set.member name existingNames then
                toNameThatWontClash options NameBasedOffOfFieldPlusSchemaType

            else
                name

        NameBasedOffOfFieldPlusSchemaType ->
            let
                name : String
                name =
                    String.join "_"
                        [ String.Extra.toSentenceCase field.name
                        , Schema.toTypeRefName field.type_
                        ]
            in
            if Set.member name existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlusSchemaTypePlus 2)

            else
                name

        NameBasedOffOfFieldPlusSchemaTypePlus num ->
            let
                name : String
                name =
                    String.join "_"
                        [ String.Extra.toSentenceCase field.name
                        , Schema.toTypeRefName field.type_
                        , String.fromInt num
                        ]
            in
            if Set.member name existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlusSchemaTypePlus (num + 1))

            else
                name


toDataAnnotation : Options -> CodeGen.Annotation
toDataAnnotation ({ schema, document } as options) =
    let
        firstQuerySelectionSet : List Document.Selection
        firstQuerySelectionSet =
            Document.toRootSelections document

        maybeQueryType : Maybe Schema.ObjectType
        maybeQueryType =
            Schema.findQueryType schema
    in
    CodeGen.Annotation.multilineRecord
        (case maybeQueryType of
            Just queryType ->
                firstQuerySelectionSet
                    |> List.filterMap (toRecordField schema queryType)

            Nothing ->
                []
        )


toRecordField :
    Schema
    -> Schema.ObjectType
    -> Document.Selection
    -> Maybe ( String, CodeGen.Annotation )
toRecordField schema objectType selection =
    case selection of
        Document.Selection_Field fieldSelection ->
            case Schema.findFieldWithName fieldSelection.name objectType of
                Just fieldSchema ->
                    Just
                        ( fieldSelection.alias
                            |> Maybe.withDefault fieldSelection.name
                        , toTypeRefAnnotation fieldSchema
                        )

                Nothing ->
                    Nothing

        _ ->
            Nothing


toTypeRefAnnotation : Schema.Field -> CodeGen.Annotation
toTypeRefAnnotation field =
    Schema.toTypeRefAnnotation field.type_
        |> CodeGen.Annotation.type_
