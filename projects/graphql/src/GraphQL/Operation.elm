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
            fromSetToImportList moduleInfo.imports

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

                isUnionOrInterfaceType : Bool
                isUnionOrInterfaceType =
                    maybeField
                        |> Maybe.andThen
                            (\field ->
                                Schema.findTypeWithName
                                    (TypeRef.toName field.type_)
                                    schema
                            )
                        |> Maybe.map
                            (\t ->
                                case t of
                                    Schema.Type_Union _ ->
                                        True

                                    Schema.Type_Interface _ ->
                                        True

                                    _ ->
                                        False
                            )
                        |> Maybe.withDefault False
            in
            case maybeField of
                Just field ->
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
                    in
                    if isUnionOrInterfaceType then
                        { existingNames = newExistingNames
                        , imports =
                            Set.singleton
                                (String.join "."
                                    [ options.namespace
                                    , fromKindToFolderName options.kind
                                    , Document.toName document
                                    , typeAliasName
                                    ]
                                )
                        , declarations =
                            declarations
                                ++ [ CodeGen.Declaration.typeAlias
                                        { name = typeAliasName
                                        , annotation =
                                            String.join "."
                                                [ options.namespace
                                                , fromKindToFolderName options.kind
                                                , Document.toName document
                                                , typeAliasName
                                                , typeAliasName
                                                ]
                                                |> CodeGen.Annotation.type_
                                        }
                                   ]
                        }

                    else
                        let
                            fieldInfo :
                                { fields : List ( String, CodeGen.Annotation )
                                , imports : Set String
                                }
                            fieldInfo =
                                fieldSelection.selections
                                    |> List.concatMap (Document.toFieldSelections document)
                                    |> List.filterMap
                                        (toTypeAliasRecordPair
                                            { fieldTypeName = TypeRef.toName field.type_
                                            , existingNames = newExistingNames
                                            }
                                        )
                                    |> flattenImportsAndFields data
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

                Nothing ->
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

        toTypeAliasRecordPair :
            { fieldTypeName : String
            , existingNames : Set String
            }
            -> Document.FieldSelection
            ->
                Maybe
                    { field : ( String, CodeGen.Annotation )
                    , imports : Set String
                    }
        toTypeAliasRecordPair { fieldTypeName, existingNames } innerField =
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
                                { schema = schema
                                , namespace = options.namespace
                                , documentFieldSelection = innerField
                                , existingNames = existingNames
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
                { typeName = fieldTypeName
                , fieldName = innerField.name
                }
                schema
                |> Maybe.map toTuple

        flattenImportsAndFields :
            { data | imports : Set String }
            ->
                List
                    { field : ( String, CodeGen.Annotation )
                    , imports : Set String
                    }
            ->
                { fields : List ( String, CodeGen.Annotation )
                , imports : Set String
                }
        flattenImportsAndFields data list =
            { fields = List.map .field list
            , imports =
                List.foldl
                    (\item set -> Set.union item.imports set)
                    data.imports
                    list
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

        toUnionVariant :
            { sharedSelections : List Document.Selection
            , unionTypeName : String
            , inline : Document.InlineFragmentSelection
            }
            -> CodeGen.Expression
        toUnionVariant { sharedSelections, unionTypeName, inline } =
            let
                toQualifiedName : String -> String
                toQualifiedName inner =
                    String.join "."
                        [ options.namespace
                        , fromKindToFolderName options.kind
                        , Document.toName document
                        , unionTypeName
                        , inner
                        ]
            in
            CodeGen.Expression.multilineFunction
                { name = "GraphQL.Decode.variant"
                , arguments =
                    [ CodeGen.Expression.multilineRecord
                        [ ( "typename", inline.name |> CodeGen.Expression.string )
                        , ( "onVariant"
                          , toQualifiedName ("On_" ++ inline.name)
                                |> CodeGen.Expression.value
                          )
                        , ( "decoder"
                          , toObjectDecoder
                                { existingNames = Set.empty
                                , constructor = toQualifiedName inline.name
                                , parentType =
                                    Schema.findTypeWithName inline.name schema
                                        |> Maybe.andThen Schema.toObjectType
                                , selections = sharedSelections ++ inline.selections
                                }
                          )
                        ]
                    ]
                }

        isNotAnInlineFragmentSelection : Document.Selection -> Bool
        isNotAnInlineFragmentSelection selection =
            case selection of
                Document.Selection_InlineFragment _ ->
                    False

                Document.Selection_FragmentSpread _ ->
                    True

                Document.Selection_Field _ ->
                    True

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
                    case Schema.findFieldWithName field.name parentObjectType of
                        Just fieldSchema ->
                            let
                                typeRefName : String
                                typeRefName =
                                    TypeRef.toName fieldSchema.type_

                                toUnionOrInterfaceDecoder :
                                    { name : String }
                                    -> CodeGen.Expression
                                toUnionOrInterfaceDecoder { name } =
                                    let
                                        sharedSelections : List Document.Selection
                                        sharedSelections =
                                            field.selections
                                                |> List.filter isNotAnInlineFragmentSelection
                                    in
                                    CodeGen.Expression.multilineFunction
                                        { name = name
                                        , arguments =
                                            [ field.selections
                                                |> List.filterMap Document.toInlineFragmentSelection
                                                |> List.map
                                                    (\inlineFragmentSelections ->
                                                        toUnionVariant
                                                            { unionTypeName = typeRefName
                                                            , sharedSelections = sharedSelections
                                                            , inline = inlineFragmentSelections
                                                            }
                                                    )
                                                |> CodeGen.Expression.multilineList
                                            ]
                                        }
                                        |> toTypeRefDecoder fieldSchema.type_
                            in
                            if Schema.isBuiltInScalarType typeRefName then
                                CodeGen.Expression.value
                                    ("GraphQL.Decode.${typeRefName}"
                                        |> String.replace "${typeRefName}" (fromBuiltInScalarToFunctionName typeRefName)
                                    )
                                    |> toTypeRefDecoder fieldSchema.type_

                            else if Schema.isScalarType typeRefName schema then
                                CodeGen.Expression.value
                                    ("${namespace}.Scalars.${typeRefName}.decoder"
                                        |> String.replace "${namespace}" options.namespace
                                        |> String.replace "${typeRefName}" (String.Extra.toSentenceCase typeRefName)
                                    )
                                    |> toTypeRefDecoder fieldSchema.type_

                            else if Schema.isEnumType typeRefName schema then
                                CodeGen.Expression.value
                                    ("${namespace}.Enum.${typeRefName}.decoder"
                                        |> String.replace "${namespace}" options.namespace
                                        |> String.replace "${typeRefName}" (String.Extra.toSentenceCase typeRefName)
                                    )
                                    |> toTypeRefDecoder fieldSchema.type_

                            else if Schema.isUnionType typeRefName schema then
                                toUnionOrInterfaceDecoder
                                    { name = "GraphQL.Decode.union"
                                    }

                            else if Schema.isInterfaceType typeRefName schema then
                                toUnionOrInterfaceDecoder
                                    { name = "GraphQL.Decode.interface"
                                    }

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

        unionTypeModules : List CodeGen.Module
        unionTypeModules =
            Document.toAllSelections schema document
                |> List.concatMap toUnionTypeModules

        toUnionTypeModules : { parent : Schema.Type, selection : Document.Selection } -> List CodeGen.Module
        toUnionTypeModules { parent, selection } =
            let
                toTypeForSelection : String -> Maybe Schema.Type
                toTypeForSelection fieldName =
                    Schema.findFieldForType
                        { typeName = Schema.toTypeName parent
                        , fieldName = fieldName
                        }
                        schema
                        |> Maybe.andThen (\f -> Schema.findTypeWithName (TypeRef.toName f.type_) schema)

                toModulesForNestedSelections :
                    { info
                        | selections : List Document.Selection
                        , name : String
                    }
                    -> List CodeGen.Module
                toModulesForNestedSelections inner =
                    List.concatMap
                        (\nextSelection ->
                            case toTypeForSelection inner.name of
                                Nothing ->
                                    []

                                Just nextParent ->
                                    toUnionTypeModules
                                        { parent = nextParent
                                        , selection = nextSelection
                                        }
                        )
                        inner.selections
            in
            case selection of
                Document.Selection_FragmentSpread inner ->
                    []

                Document.Selection_Field inner ->
                    let
                        modules : List CodeGen.Module
                        modules =
                            if List.any Document.isInlineFragment inner.selections then
                                toTypeForSelection inner.name
                                    |> Maybe.map (toUnionOrInterfaceTypeModule inner.selections)
                                    |> Maybe.map List.singleton
                                    |> Maybe.withDefault []

                            else
                                []
                    in
                    modules ++ toModulesForNestedSelections inner

                Document.Selection_InlineFragment inner ->
                    toModulesForNestedSelections inner

        toUnionOrInterfaceTypeModule : List Document.Selection -> Schema.Type -> CodeGen.Module
        toUnionOrInterfaceTypeModule selections type_ =
            let
                unionType : { name : String }
                unionType =
                    case type_ of
                        Schema.Type_Union union ->
                            { name = union.name }

                        Schema.Type_Interface interface ->
                            { name = interface.name }

                        _ ->
                            { name = "HOWDY_DO_DATS" }

                inlineFragmentSelections : List Document.InlineFragmentSelection
                inlineFragmentSelections =
                    selections
                        |> List.filterMap Document.toInlineFragmentSelection

                sharedSelections : List Document.Selection
                sharedSelections =
                    selections
                        |> List.filter isNotAnInlineFragmentSelection

                customType : CodeGen.Declaration
                customType =
                    CodeGen.Declaration.customType
                        { name = unionType.name
                        , variants =
                            inlineFragmentSelections
                                |> List.map
                                    (\selection ->
                                        ( "On_" ++ selection.name
                                        , [ CodeGen.Annotation.type_ selection.name ]
                                        )
                                    )
                        }

                toInfo :
                    Document.InlineFragmentSelection
                    ->
                        { name : String
                        , declaration : CodeGen.Declaration
                        , imports : Set String
                        }
                toInfo selection =
                    let
                        fieldInfo :
                            { fields : List ( String, CodeGen.Annotation )
                            , imports : Set String
                            }
                        fieldInfo =
                            (sharedSelections ++ selection.selections)
                                |> List.concatMap (Document.toFieldSelections document)
                                |> List.filterMap
                                    (toTypeAliasRecordPair
                                        { fieldTypeName = selection.name
                                        , existingNames = Set.empty
                                        }
                                    )
                                |> flattenImportsAndFields { imports = Set.empty }
                    in
                    { name = selection.name
                    , declaration =
                        CodeGen.Declaration.typeAlias
                            { name = selection.name
                            , annotation = CodeGen.Annotation.multilineRecord fieldInfo.fields
                            }
                    , imports = fieldInfo.imports
                    }

                addToInfo :
                    { name : String
                    , declaration : CodeGen.Declaration
                    , imports : Set String
                    }
                    ->
                        { variantNames : List String
                        , typeAnnotations : List CodeGen.Declaration
                        , importsFromAnnotations : Set String
                        }
                    ->
                        { variantNames : List String
                        , typeAnnotations : List CodeGen.Declaration
                        , importsFromAnnotations : Set String
                        }
                addToInfo item info =
                    { variantNames = info.variantNames ++ [ item.name ]
                    , typeAnnotations = info.typeAnnotations ++ [ item.declaration ]
                    , importsFromAnnotations = Set.union info.importsFromAnnotations item.imports
                    }

                { variantNames, typeAnnotations, importsFromAnnotations } =
                    inlineFragmentSelections
                        |> List.map toInfo
                        |> List.foldl addToInfo
                            { variantNames = []
                            , typeAnnotations = []
                            , importsFromAnnotations = Set.empty
                            }
            in
            CodeGen.Module.new
                { name =
                    [ options.namespace
                    , fromKindToFolderName options.kind
                    , Document.toName document
                    , unionType.name
                    ]
                , imports = fromSetToImportList importsFromAnnotations
                , exposing_ = []
                , declarations =
                    List.concat
                        [ [ customType ]
                        , typeAnnotations
                        ]
                }
                |> CodeGen.Module.withOrderedExposingList
                    [ [ unionType.name ++ "(..)" ]
                    , variantNames
                    ]

        operationInputModules : List CodeGen.Module
        operationInputModules =
            if Document.hasVariables document then
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
                    , toTypeNameUnwrappingFirstMaybe = .type_ >> DocumentType.toStringUnwrappingFirstMaybe options.namespace schema
                    , toTypeName = .type_ >> DocumentType.toName
                    , toEncoderString = .type_ >> DocumentType.toEncoderStringUnwrappingFirstMaybe options.namespace schema
                    , isInputObject = False
                    }
                ]

            else
                []
    in
    Result.map
        (\dataTypeAlias ->
            List.concat
                [ [ toOperationModule dataTypeAlias ]
                , unionTypeModules
                , operationInputModules
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
                                options.namespace
                                Set.empty
                                schema
                                operationType
                            )
                        )

            Nothing ->
                Err GraphQL.CliError.CouldNotFindOperationType
        )


toRecordField :
    String
    -> Set String
    -> Schema
    -> Schema.ObjectType
    -> Document.Selection
    -> Maybe ( String, CodeGen.Annotation )
toRecordField namespace existingTypeAliasNames schema objectType selection =
    case selection of
        Document.Selection_Field field ->
            case Schema.findFieldWithName field.name objectType of
                Just fieldSchema ->
                    Just
                        (let
                            { annotation } =
                                toTypeRefAnnotation
                                    { namespace = namespace
                                    , schema = schema
                                    , documentFieldSelection = field
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


fromSetToImportList : Set String -> List CodeGen.Import
fromSetToImportList set =
    set
        |> Set.toList
        |> List.map (String.split "." >> CodeGen.Import.new)


toTypeRefAnnotation :
    { namespace : String
    , schema : Schema
    , documentFieldSelection : Document.FieldSelection
    , existingNames : Set String
    , field : Schema.Field
    , matchingFragmentName : Maybe String
    }
    ->
        { annotation : CodeGen.Annotation
        , imports : Set String
        }
toTypeRefAnnotation { namespace, schema, documentFieldSelection, existingNames, field, matchingFragmentName } =
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

        fieldTypeName =
            TypeRef.toName field.type_

        ( typeAliasName, imports ) =
            case fieldTypeName of
                "ID" ->
                    ( "GraphQL.Scalar.Id.Id"
                    , Set.singleton "GraphQL.Scalar.Id"
                    )

                "Boolean" ->
                    ( "Bool"
                    , Set.empty
                    )

                _ ->
                    if Schema.isBuiltInScalarType fieldTypeName then
                        ( originalName, Set.empty )

                    else if Schema.isEnumType fieldTypeName schema then
                        ( String.join "." [ namespace, "Enum", originalName, originalName ]
                        , Set.singleton (String.join "." [ namespace, "Enum", originalName ])
                        )

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


fromBuiltInScalarToFunctionName : String -> String
fromBuiltInScalarToFunctionName str =
    case str of
        "String" ->
            "string"

        "Int" ->
            "int"

        "Float" ->
            "float"

        "Boolean" ->
            "bool"

        _ ->
            String.toLower str
