module GraphQL.Operation exposing
    ( Kind(..)
    , generate
    )

{-| In GraphQL, an "operation" is either a query or a mutation.

This module allows you to generate either from a server-side "Schema" and a client-side "Document".

@docs Kind
@docs generate

-}

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.CliError exposing (CliError)
import GraphQL.Input
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Document.Type as DocumentType
import GraphQL.Introspection.Document.VariableDefinition as VariableDefinition
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import GraphQL.Introspection.Schema.TypeRef as TypeRef exposing (TypeRef)
import Set exposing (Set)
import String.Extra


type Kind
    = Query
    | Mutation


fromKindToFolderName : Kind -> String
fromKindToFolderName kind =
    case kind of
        Query ->
            "Queries"

        Mutation ->
            "Mutations"


fromKindToOperationType : Kind -> Schema -> Maybe Schema.ObjectType
fromKindToOperationType kind schema =
    case kind of
        Mutation ->
            Schema.findMutationType schema

        Query ->
            Schema.findQueryType schema


fromKindToOperationTypeName : Kind -> Schema -> String
fromKindToOperationTypeName kind schema =
    case kind of
        Mutation ->
            Schema.toMutationTypeName schema

        Query ->
            Schema.toQueryTypeName schema


generate :
    { namespace : String
    , kind : Kind
    , schema : Schema
    , document : Document
    }
    -> Result CliError (List CodeGen.Module)
generate ({ schema, document } as options) =
    toModules options


type alias Options =
    { namespace : String
    , kind : Kind
    , schema : Schema
    , document : Document
    }


type alias ModuleInfo =
    { existingNames : Set String
    , imports : Set String
    , declarations : List CodeGen.Declaration
    }


toModules : Options -> Result CliError (List CodeGen.Module)
toModules ({ schema, document } as options) =
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

        moduleInfo : ModuleInfo
        moduleInfo =
            Document.getNestedFields
                (fromKindToOperationTypeName options.kind schema)
                schema
                document
                |> List.foldl toNestedTypeAlias
                    { existingNames = Set.singleton "Data"
                    , imports = Set.empty
                    , declarations = []
                    }

        nestedTypeAliases : List CodeGen.Declaration
        nestedTypeAliases =
            moduleInfo.declarations

        exposedTypeAliases : List String
        exposedTypeAliases =
            moduleInfo.existingNames
                |> Set.remove "Data"
                |> Set.toList

        extraImports : List CodeGen.Import
        extraImports =
            moduleInfo.imports
                |> Set.toList
                |> List.map (String.split "." >> CodeGen.Import.new)

        inputTypeImports : List CodeGen.Import
        inputTypeImports =
            if Document.hasVariables document then
                [ CodeGen.Import.new
                    [ options.namespace
                    , fromKindToFolderName options.kind
                    , Document.toName document
                    , "Input"
                    ]
                ]

            else
                []

        toNestedTypeAlias :
            { parentTypeName : String
            , fieldSelection : Document.FieldSelection
            }
            -> ModuleInfo
            -> ModuleInfo
        toNestedTypeAlias { parentTypeName, fieldSelection } ({ existingNames, declarations } as data) =
            let
                parentObjectType : Maybe Schema.ObjectType
                parentObjectType =
                    Schema.findTypeWithName parentTypeName schema
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
                                    (TypeRef.toName field.type_)
                                    schema
                            )
                        |> Maybe.andThen Schema.toObjectType
            in
            case ( maybeField, maybeObjectType ) of
                ( Just field, _ ) ->
                    let
                        typeAliasName : String
                        typeAliasName =
                            case toOnlyMatchingFragmentName fieldSelection of
                                Just fragName ->
                                    toNameThatWontClash
                                        { alias_ = fieldSelection.alias
                                        , field = field
                                        , existingNames = existingNames
                                        }
                                        (NameBasedOffOfFragment fragName)

                                Nothing ->
                                    toNameThatWontClash
                                        { alias_ = fieldSelection.alias
                                        , field = field
                                        , existingNames = existingNames
                                        }
                                        NameBasedOffOfSchemaType

                        newExistingNames : Set String
                        newExistingNames =
                            Set.insert typeAliasName existingNames

                        toTypeAliasRecordPair :
                            Document.FieldSelection
                            ->
                                Maybe
                                    { field : ( String, CodeGen.Annotation )
                                    , imports : Set String
                                    }
                        toTypeAliasRecordPair innerField =
                            let
                                toTuple :
                                    Schema.Field
                                    ->
                                        { field : ( String, CodeGen.Annotation )
                                        , imports : Set String
                                        }
                                toTuple schemaField =
                                    let
                                        { annotation, imports } =
                                            toTypeRefAnnotation
                                                { documentFieldSelection = innerField
                                                , existingNames = newExistingNames
                                                , field = schemaField
                                                , matchingFragmentName = toOnlyMatchingFragmentName innerField
                                                }
                                    in
                                    { field =
                                        ( innerField.alias
                                            |> Maybe.withDefault innerField.name
                                        , annotation
                                        )
                                    , imports = imports
                                    }
                            in
                            Schema.findFieldForType
                                { typeName = TypeRef.toName field.type_
                                , fieldName = innerField.name
                                }
                                schema
                                |> Maybe.map toTuple

                        flattenImportsAndFields :
                            List
                                { field : ( String, CodeGen.Annotation )
                                , imports : Set String
                                }
                            ->
                                { fields : List ( String, CodeGen.Annotation )
                                , imports : Set String
                                }
                        flattenImportsAndFields list =
                            { fields = List.map .field list
                            , imports =
                                List.foldl
                                    (\item set -> Set.union item.imports set)
                                    data.imports
                                    list
                            }

                        fieldInfo :
                            { fields : List ( String, CodeGen.Annotation )
                            , imports : Set String
                            }
                        fieldInfo =
                            fieldSelection.selections
                                |> List.concatMap (Document.toFieldSelections document)
                                |> List.filterMap toTypeAliasRecordPair
                                |> flattenImportsAndFields
                    in
                    { existingNames = newExistingNames
                    , imports = fieldInfo.imports
                    , declarations =
                        declarations
                            ++ [ CodeGen.Declaration.typeAlias
                                    { name = typeAliasName
                                    , annotation =
                                        fieldInfo.fields
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
                                , ( "variables"
                                  , if Document.hasVariables document then
                                        "${namespace}.${folderName}.${name}.Input.toInternalValue input"
                                            |> String.replace "${namespace}" options.namespace
                                            |> String.replace "${folderName}" (fromKindToFolderName options.kind)
                                            |> String.replace "${name}" (Document.toName document)
                                            |> CodeGen.Expression.value

                                    else
                                        CodeGen.Expression.list []
                                  )
                                , ( "decoder", CodeGen.Expression.value "decoder" )
                                ]
                            ]
                        }
            in
            CodeGen.Declaration.function
                { name = "new"
                , annotation =
                    if Document.hasVariables document then
                        CodeGen.Annotation.type_ "Input -> GraphQL.Operation.Operation Data"

                    else
                        CodeGen.Annotation.type_ "GraphQL.Operation.Operation Data"
                , arguments =
                    if Document.hasVariables document then
                        [ CodeGen.Argument.new "input" ]

                    else
                        []
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
                        , parentType = fromKindToOperationType options.kind schema
                        , selections =
                            Document.toRootSelections document
                                |> Result.withDefault []
                        }
                }

        toTypeRefDecoder :
            TypeRef
            -> CodeGen.Expression
            -> CodeGen.Expression
        toTypeRefDecoder typeRef innerExpression =
            let
                toElmTypeRefExpression : TypeRef.ElmTypeRef -> CodeGen.Expression
                toElmTypeRefExpression elmTypeRef =
                    case elmTypeRef of
                        TypeRef.ElmTypeRef_Named _ ->
                            innerExpression

                        TypeRef.ElmTypeRef_List innerElmTypeRef ->
                            CodeGen.Expression.pipeline
                                [ toElmTypeRefExpression innerElmTypeRef
                                , CodeGen.Expression.value "GraphQL.Decode.list"
                                ]

                        TypeRef.ElmTypeRef_Maybe innerElmTypeRef ->
                            CodeGen.Expression.pipeline
                                [ toElmTypeRefExpression innerElmTypeRef
                                , CodeGen.Expression.value "GraphQL.Decode.maybe"
                                ]
            in
            toElmTypeRefExpression (TypeRef.toElmTypeRef typeRef)

        toFieldDecoderForSelection :
            { existingNames : Set String
            , parentObjectType : Schema.ObjectType
            , field : Document.FieldSelection
            , matchingFragmentName : Maybe String
            }
            -> CodeGen.Expression
        toFieldDecoderForSelection { matchingFragmentName, existingNames, parentObjectType, field } =
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
                                    TypeRef.toName fieldSchema.type_
                            in
                            if Schema.isBuiltInScalarType typeRefName then
                                CodeGen.Expression.value
                                    ("GraphQL.Decode.${typeRefName}"
                                        |> String.replace "${typeRefName}" (String.toLower typeRefName)
                                    )
                                    |> toTypeRefDecoder fieldSchema.type_

                            else if Schema.isScalarType typeRefName schema then
                                CodeGen.Expression.value
                                    ("${namespace}.Scalars.${typeRefName}.decoder"
                                        |> String.replace "${namespace}" options.namespace
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
                                            (matchingFragmentName
                                                |> Maybe.map NameBasedOffOfFragment
                                                |> Maybe.withDefault NameBasedOffOfSchemaType
                                            )
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

        toFieldDecoder :
            Set String
            -> Schema.ObjectType
            -> Document.Selection
            -> CodeGen.Expression
        toFieldDecoder existingNames parentObjectType selection =
            case selection of
                Document.Selection_Field field ->
                    toFieldDecoderForSelection
                        { existingNames = existingNames
                        , parentObjectType = parentObjectType
                        , field = field
                        , matchingFragmentName = toOnlyMatchingFragmentName field
                        }

                Document.Selection_FragmentSpread { name } ->
                    case Document.findFragmentDefinitionWithName name document of
                        Just fragment ->
                            Schema.findTypeWithName fragment.typeName schema
                                |> Maybe.andThen Schema.toObjectType
                                |> Maybe.map
                                    (\objectType ->
                                        fragment.selections
                                            |> List.map (toFieldDecoder existingNames objectType)
                                    )
                                |> Maybe.map CodeGen.Expression.pipeline
                                |> Maybe.withDefault (CodeGen.Expression.pipeline [])

                        Nothing ->
                            CodeGen.Expression.value "Debug.todo \"Selection_FragmentSpread\""

                Document.Selection_InlineFragment fragment ->
                    CodeGen.Expression.value "Debug.todo \"Selection_InlineFragment\""

        inputTypeAlias : CodeGen.Declaration
        inputTypeAlias =
            CodeGen.Declaration.typeAlias
                { name = "Input"
                , annotation =
                    "${namespace}.${folderName}.${name}.Input.Input {}"
                        |> String.replace "${namespace}" options.namespace
                        |> String.replace "${folderName}" (fromKindToFolderName options.kind)
                        |> String.replace "${name}" (Document.toName document)
                        |> CodeGen.Annotation.type_
                }

        toOperationModule : CodeGen.Declaration -> CodeGen.Module
        toOperationModule dataTypeAlias =
            CodeGen.Module.new
                { name =
                    [ options.namespace
                    , fromKindToFolderName options.kind
                    , Document.toName document
                    ]
                , exposing_ = []
                , imports =
                    [ CodeGen.Import.new [ "GraphQL", "Decode" ]
                    , CodeGen.Import.new [ "GraphQL", "Operation" ]
                    ]
                        ++ inputTypeImports
                        ++ extraImports
                , declarations =
                    List.concat
                        [ if Document.hasVariables document then
                            [ CodeGen.Declaration.comment [ "INPUT" ]
                            , inputTypeAlias
                            ]

                          else
                            []
                        , [ CodeGen.Declaration.comment [ "OUTPUT" ]
                          , dataTypeAlias
                          ]
                        , nestedTypeAliases
                        , [ CodeGen.Declaration.comment [ "OPERATION" ]
                          , newFunction
                          , decoderFunction
                          ]
                        ]
                }
                |> CodeGen.Module.withOrderedExposingList
                    [ if Document.hasVariables document then
                        [ "Input", "Data", "new" ]

                      else
                        [ "Data", "new" ]
                    , exposedTypeAliases
                    ]
    in
    Result.map
        (\dataTypeAlias ->
            List.concat
                [ [ toOperationModule dataTypeAlias ]
                , if Document.hasVariables document then
                    [ GraphQL.Input.toInputModule
                        { inputTypeName = "Input"
                        , moduleName =
                            [ options.namespace
                            , fromKindToFolderName options.kind
                            , Document.toName document
                            , "Input"
                            ]
                        , namespace = options.namespace
                        , schema = options.schema
                        , variables = Document.toVariables document
                        , isRequired = VariableDefinition.isRequired
                        , toVarName = .name
                        , toTypeNameUnwrappingFirstMaybe = .type_ >> DocumentType.toStringUnwrappingFirstMaybe schema
                        , toTypeName = .type_ >> DocumentType.toName
                        , toEncoderString = .type_ >> DocumentType.toEncoderStringUnwrappingFirstMaybe schema
                        , isInputObject = False
                        }
                    ]

                  else
                    []
                ]
        )
        dataTypeAliasResult


toOnlyMatchingFragmentName :
    Document.FieldSelection
    -> Maybe String
toOnlyMatchingFragmentName field_ =
    case field_.selections of
        (Document.Selection_FragmentSpread frag) :: [] ->
            Just frag.name

        _ ->
            Nothing


type NameAttempt
    = NameBasedOffOfSchemaType
    | NameBasedOffOfFragment String
    | NameBasedOffOfFieldPlus String
    | NameBasedOffOfFieldPlusNumber Int String


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
                    TypeRef.toName field.type_
            in
            if Set.member name existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlus name)

            else
                name

        NameBasedOffOfFragment fragmentName ->
            if Set.member fragmentName existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlus fragmentName)

            else
                fragmentName

        NameBasedOffOfFieldPlus baseName ->
            let
                name : String
                name =
                    String.join "_"
                        [ String.Extra.toSentenceCase (alias_ |> Maybe.withDefault field.name)
                        , baseName
                        ]
            in
            if Set.member name existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlusNumber 2 baseName)

            else
                name

        NameBasedOffOfFieldPlusNumber num baseName ->
            let
                name : String
                name =
                    String.join "_"
                        [ String.Extra.toSentenceCase (alias_ |> Maybe.withDefault field.name)
                        , baseName
                        , String.fromInt num
                        ]
            in
            if Set.member name existingNames then
                toNameThatWontClash options (NameBasedOffOfFieldPlusNumber (num + 1) baseName)

            else
                name


toDataAnnotation : Options -> Result CliError CodeGen.Annotation
toDataAnnotation ({ schema, document } as options) =
    let
        rootSelectionSet : Result CliError (List Document.Selection)
        rootSelectionSet =
            Document.toRootSelections document

        maybeOperationType : Maybe Schema.ObjectType
        maybeOperationType =
            fromKindToOperationType options.kind schema
    in
    Result.map CodeGen.Annotation.multilineRecord
        (case maybeOperationType of
            Just operationType ->
                rootSelectionSet
                    |> Result.map
                        (List.filterMap
                            (toRecordField
                                Set.empty
                                schema
                                operationType
                            )
                        )

            Nothing ->
                Err GraphQL.CliError.CouldNotFindOperationType
        )


toRecordField :
    Set String
    -> Schema
    -> Schema.ObjectType
    -> Document.Selection
    -> Maybe ( String, CodeGen.Annotation )
toRecordField existingTypeAliasNames schema objectType selection =
    case selection of
        Document.Selection_Field field ->
            case Schema.findFieldWithName field.name objectType of
                Just fieldSchema ->
                    Just
                        (let
                            { annotation } =
                                toTypeRefAnnotation
                                    { documentFieldSelection = field
                                    , existingNames = existingTypeAliasNames
                                    , field = fieldSchema
                                    , matchingFragmentName = toOnlyMatchingFragmentName field
                                    }
                         in
                         ( field.alias
                            |> Maybe.withDefault field.name
                         , annotation
                         )
                        )

                Nothing ->
                    Nothing

        _ ->
            Nothing


toTypeRefAnnotation :
    { documentFieldSelection : Document.FieldSelection
    , existingNames : Set String
    , field : Schema.Field
    , matchingFragmentName : Maybe String
    }
    ->
        { annotation : CodeGen.Annotation
        , imports : Set String
        }
toTypeRefAnnotation { documentFieldSelection, existingNames, field, matchingFragmentName } =
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
                (matchingFragmentName
                    |> Maybe.map NameBasedOffOfFragment
                    |> Maybe.withDefault NameBasedOffOfSchemaType
                )

        ( typeAliasName, imports ) =
            case TypeRef.toName field.type_ of
                "ID" ->
                    ( "GraphQL.Scalar.Id.Id"
                    , Set.singleton "GraphQL.Scalar.Id"
                    )

                _ ->
                    if Schema.isBuiltInScalarType (TypeRef.toName field.type_) then
                        ( originalName, Set.empty )

                    else
                        ( originalName, Set.empty )
    in
    { annotation =
        CodeGen.Annotation.type_
            (TypeRef.toAnnotation
                typeAliasName
                field.type_
            )
    , imports = imports
    }
