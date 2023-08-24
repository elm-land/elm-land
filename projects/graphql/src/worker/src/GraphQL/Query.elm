module GraphQL.Query exposing (generate)

import CodeGen
import CodeGen.Annotation
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.CliError exposing (CliError)
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import Set exposing (Set)
import String.Extra


type alias File =
    { filepath : List String
    , contents : String
    }


generate : { schema : Schema, document : Document } -> Result CliError File
generate ({ schema, document } as options) =
    toModule options
        |> Result.map
            (\module_ ->
                { filepath =
                    [ "GraphQL"
                    , "Queries"
                    , Document.toName document ++ ".elm"
                    ]
                , contents =
                    CodeGen.Module.toString module_
                }
            )


type alias Options =
    { schema : Schema
    , document : Document
    }


toModule : Options -> Result CliError CodeGen.Module
toModule ({ schema, document } as options) =
    let
        dataTypeAliasResult : Result CliError CodeGen.Declaration
        dataTypeAliasResult =
            toDataAnnotation options
                |> Result.map
                    (\anno ->
                        CodeGen.Declaration.typeAlias
                            { name = "Data"
                            , annotation = anno
                            }
                    )

        nestedTypeAliases : List CodeGen.Declaration
        nestedTypeAliases =
            Document.getNestedFields schema document
                |> List.foldl toNestedTypeAlias
                    { existingNames = Set.singleton "Data"
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
                                { alias_ = fieldSelection.alias
                                , field = field
                                , existingNames = existingNames
                                }
                                NameBasedOffOfSchemaType

                        newExistingNames : Set String
                        newExistingNames =
                            Set.insert typeAliasName existingNames
                    in
                    { existingNames = newExistingNames
                    , declarations =
                        declarations
                            ++ [ CodeGen.Declaration.typeAlias
                                    { name = typeAliasName
                                    , annotation =
                                        fieldSelection.selections
                                            |> List.filterMap Document.toFieldSelection
                                            |> List.filterMap
                                                (\innerField ->
                                                    Schema.findFieldForType
                                                        { typeName = Schema.toTypeRefName field.type_
                                                        , fieldName = innerField.name
                                                        }
                                                        schema
                                                        |> Maybe.map
                                                            (toTypeRefAnnotation
                                                                innerField
                                                                newExistingNames
                                                            )
                                                        |> Maybe.map
                                                            (Tuple.pair
                                                                (innerField.alias
                                                                    |> Maybe.withDefault innerField.name
                                                                )
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

        toObjectDecoder :
            { constructor : String
            , existingNames : Set String
            , parentType : Maybe Schema.ObjectType
            , selections : List Document.Selection
            }
            -> CodeGen.Expression
        toObjectDecoder props =
            CodeGen.Expression.pipeline
                (List.concat
                    [ [ CodeGen.Expression.value
                            ("GraphQL.Decode.object " ++ props.constructor)
                      ]
                    , case props.parentType of
                        Nothing ->
                            []

                        Just parentType ->
                            List.map (toFieldDecoder props.existingNames parentType) props.selections
                    ]
                )

        decoderFunction : CodeGen.Declaration
        decoderFunction =
            CodeGen.Declaration.function
                { name = "decoder"
                , annotation = CodeGen.Annotation.type_ "GraphQL.Decode.Decoder Data"
                , arguments = []
                , expression =
                    toObjectDecoder
                        { constructor = "Data"
                        , existingNames = Set.singleton "Data"
                        , parentType = Schema.findQueryType schema
                        , selections =
                            Document.toRootSelections document
                                |> Result.withDefault []
                        }
                }

        toTypeRefDecoder :
            Schema.TypeRef
            -> CodeGen.Expression
            -> CodeGen.Expression
        toTypeRefDecoder typeRef innerExpression =
            let
                toElmTypeRefExpression : Schema.ElmTypeRef -> CodeGen.Expression
                toElmTypeRefExpression elmTypeRef =
                    case elmTypeRef of
                        Schema.ElmTypeRef_Named _ ->
                            innerExpression

                        Schema.ElmTypeRef_List innerElmTypeRef ->
                            CodeGen.Expression.pipeline
                                [ toElmTypeRefExpression innerElmTypeRef
                                , CodeGen.Expression.value "GraphQL.Decode.list"
                                ]

                        Schema.ElmTypeRef_Maybe innerElmTypeRef ->
                            CodeGen.Expression.pipeline
                                [ toElmTypeRefExpression innerElmTypeRef
                                , CodeGen.Expression.value "GraphQL.Decode.maybe"
                                ]
            in
            toElmTypeRefExpression (Schema.toElmTypeRef typeRef)

        toFieldDecoder :
            Set String
            -> Schema.ObjectType
            -> Document.Selection
            -> CodeGen.Expression
        toFieldDecoder existingNames parentObjectType selection =
            case selection of
                Document.Selection_Field field ->
                    let
                        decoder : CodeGen.Expression
                        decoder =
                            case
                                Schema.findFieldWithName
                                    field.name
                                    parentObjectType
                            of
                                Just fieldSchema ->
                                    let
                                        typeRefName : String
                                        typeRefName =
                                            Schema.toTypeRefName fieldSchema.type_
                                    in
                                    if Schema.isBuiltInScalarType fieldSchema.type_ then
                                        CodeGen.Expression.value
                                            ("GraphQL.Decode.${typeRefName}"
                                                |> String.replace "${typeRefName}" (String.toLower typeRefName)
                                            )
                                            |> toTypeRefDecoder fieldSchema.type_

                                    else if Schema.isScalarType fieldSchema.type_ schema then
                                        CodeGen.Expression.value
                                            ("GraphQL.Scalars.${typeRefName}.decoder"
                                                |> String.replace "${typeRefName}" (String.Extra.toSentenceCase typeRefName)
                                            )
                                            |> toTypeRefDecoder fieldSchema.type_

                                    else
                                        let
                                            constructor : String
                                            constructor =
                                                toNameThatWontClash
                                                    { alias_ = field.alias
                                                    , field = fieldSchema
                                                    , existingNames = existingNames
                                                    }
                                                    NameBasedOffOfSchemaType
                                        in
                                        toObjectDecoder
                                            { existingNames =
                                                existingNames
                                                    |> Set.insert constructor
                                            , constructor = constructor
                                            , parentType =
                                                Schema.findTypeWithName typeRefName schema
                                                    |> Maybe.andThen Schema.toObjectType
                                            , selections = field.selections
                                            }
                                            |> toTypeRefDecoder fieldSchema.type_

                                Nothing ->
                                    CodeGen.Expression.value "Debug.todo \"Handle Nothing branch for Schema.findFieldWithName\""
                    in
                    CodeGen.Expression.multilineFunction
                        { name = "GraphQL.Decode.field"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "name"
                                  , CodeGen.Expression.string
                                        (field.alias
                                            |> Maybe.withDefault field.name
                                        )
                                  )
                                , ( "decoder"
                                  , decoder
                                  )
                                ]
                            ]
                        }

                Document.Selection_FragmentSpread fragment ->
                    CodeGen.Expression.value "Debug.todo \"Selection_FragmentSpread\""

                Document.Selection_InlineFragment fragment ->
                    CodeGen.Expression.value "Debug.todo \"Selection_InlineFragment\""
    in
    Result.map
        (\dataTypeAlias ->
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
        )
        dataTypeAliasResult


type NameAttempt
    = NameBasedOffOfSchemaType
    | NameBasedOffOfFieldPlusSchemaType
    | NameBasedOffOfFieldPlusSchemaTypePlus Int


toNameThatWontClash :
    { alias_ : Maybe String
    , field : Schema.Field
    , existingNames : Set String
    }
    -> NameAttempt
    -> String
toNameThatWontClash ({ alias_, field, existingNames } as options) nameAttempt =
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
                        [ String.Extra.toSentenceCase (alias_ |> Maybe.withDefault field.name)
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
                        [ String.Extra.toSentenceCase (alias_ |> Maybe.withDefault field.name)
                        , Schema.toTypeRefName field.type_
                        , String.fromInt num
                        ]
            in
            if Set.member name existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlusSchemaTypePlus (num + 1))

            else
                name


toDataAnnotation : Options -> Result CliError CodeGen.Annotation
toDataAnnotation ({ schema, document } as options) =
    let
        firstQuerySelectionSet : Result CliError (List Document.Selection)
        firstQuerySelectionSet =
            Document.toRootSelections document

        maybeQueryType : Maybe Schema.ObjectType
        maybeQueryType =
            Schema.findQueryType schema
    in
    Result.map CodeGen.Annotation.multilineRecord
        (case maybeQueryType of
            Just queryType ->
                firstQuerySelectionSet
                    |> Result.map
                        (List.filterMap
                            (toRecordField
                                Set.empty
                                schema
                                queryType
                            )
                        )

            Nothing ->
                Err GraphQL.CliError.CouldNotFindQueryType
        )


toRecordField :
    Set String
    -> Schema
    -> Schema.ObjectType
    -> Document.Selection
    -> Maybe ( String, CodeGen.Annotation )
toRecordField existingTypeAliasNames schema objectType selection =
    case selection of
        Document.Selection_Field fieldSelection ->
            case Schema.findFieldWithName fieldSelection.name objectType of
                Just fieldSchema ->
                    Just
                        ( fieldSelection.alias
                            |> Maybe.withDefault fieldSelection.name
                        , toTypeRefAnnotation
                            fieldSelection
                            existingTypeAliasNames
                            fieldSchema
                        )

                Nothing ->
                    Nothing

        _ ->
            Nothing


toTypeRefAnnotation :
    Document.FieldSelection
    -> Set String
    -> Schema.Field
    -> CodeGen.Annotation
toTypeRefAnnotation documentFieldSelection existingNames field =
    let
        -- TODO: This won't work when there are two selections
        -- on the same object type within one selection (Ex. "coworkers" and "manager")
        originalName : String
        originalName =
            toNameThatWontClash
                { alias_ = documentFieldSelection.alias
                , field = field
                , existingNames = existingNames
                }
                NameBasedOffOfSchemaType

        typeAliasName =
            case Schema.toTypeRefName field.type_ of
                "ID" ->
                    "GraphQL.Scalar.Id.Id"

                _ ->
                    if Schema.isBuiltInScalarType field.type_ then
                        originalName

                    else
                        originalName
    in
    CodeGen.Annotation.type_
        (Schema.toTypeRefAnnotation
            typeAliasName
            field.type_
        )
