module GraphQL.Query exposing (generate)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.CliError exposing (CliError)
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Document.Type as DocumentType
import GraphQL.Introspection.Document.VariableDefinition as VariableDefinition
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import Set exposing (Set)
import String.Extra


type alias File =
    { filepath : List String
    , contents : String
    }


generate :
    { schema : Schema, document : Document }
    -> Result CliError (List File)
generate ({ schema, document } as options) =
    toModules options
        |> Result.map
            (List.map
                (\module_ ->
                    { filepath =
                        CodeGen.Module.toFilepath module_
                            |> String.split "/"
                    , contents =
                        CodeGen.Module.toString module_
                    }
                )
            )


type alias Options =
    { schema : Schema
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
            Document.getNestedFields schema document
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
                    [ "GraphQL"
                    , "Queries"
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
                                                innerField
                                                newExistingNames
                                                schemaField
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
                                { typeName = Schema.toTypeRefName field.type_
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

                        foo :
                            { fields : List ( String, CodeGen.Annotation )
                            , imports : Set String
                            }
                        foo =
                            fieldSelection.selections
                                |> List.filterMap Document.toFieldSelection
                                |> List.filterMap toTypeAliasRecordPair
                                |> flattenImportsAndFields
                    in
                    { existingNames = newExistingNames
                    , imports = foo.imports
                    , declarations =
                        declarations
                            ++ [ CodeGen.Declaration.typeAlias
                                    { name = typeAliasName
                                    , annotation =
                                        foo.fields
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
                                        "GraphQL.Queries.${name}.Input.toInternalValue input"
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
                                    if Schema.isBuiltInScalarType typeRefName then
                                        CodeGen.Expression.value
                                            ("GraphQL.Decode.${typeRefName}"
                                                |> String.replace "${typeRefName}" (String.toLower typeRefName)
                                            )
                                            |> toTypeRefDecoder fieldSchema.type_

                                    else if Schema.isScalarType typeRefName schema then
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

        inputTypeAlias : CodeGen.Declaration
        inputTypeAlias =
            CodeGen.Declaration.typeAlias
                { name = "Input"
                , annotation =
                    "GraphQL.Queries.${name}.Input.Input {}"
                        |> String.replace "${name}" (Document.toName document)
                        |> CodeGen.Annotation.type_
                }

        toOperationModule dataTypeAlias =
            CodeGen.Module.new
                { name =
                    [ "GraphQL"
                    , "Queries"
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
                    [ toInputModule document schema ]

                  else
                    []
                ]
        )
        dataTypeAliasResult


toInputModule : Document -> Schema -> CodeGen.Module
toInputModule document schema =
    let
        variables : List Document.VariableDefinition
        variables =
            Document.toVariables document

        extraImports : List CodeGen.Import
        extraImports =
            variables
                |> List.filterMap (.type_ >> DocumentType.toImport schema)

        requiredVariables : List Document.VariableDefinition
        requiredVariables =
            List.filter VariableDefinition.isRequired variables

        optionalVariables : List Document.VariableDefinition
        optionalVariables =
            List.filter (VariableDefinition.isRequired >> not) variables

        nullFunction : CodeGen.Declaration
        nullFunction =
            CodeGen.Declaration.function
                { name = "null"
                , annotation =
                    optionalVariables
                        |> List.map
                            (\var ->
                                ( var.name
                                , CodeGen.Annotation.type_ "Input missing -> Input missing"
                                )
                            )
                        |> CodeGen.Annotation.record
                , arguments = []
                , expression =
                    optionalVariables
                        |> List.map toRecordNullValue
                        |> CodeGen.Expression.multilineRecord
                }

        toRecordNullValue :
            Document.VariableDefinition
            -> ( String, CodeGen.Expression )
        toRecordNullValue var =
            ( var.name
            , """\\(Input dict_) -> Input (Dict.insert "${name}" GraphQL.Encode.null dict_)"""
                |> String.replace "${name}" var.name
                |> CodeGen.Expression.value
            )

        toRecordAnnotation : Document.VariableDefinition -> ( String, String )
        toRecordAnnotation var =
            ( var.name
            , DocumentType.toStringUnwrappingFirstMaybe schema var.type_
            )

        joinWithColon : ( String, String ) -> String
        joinWithColon ( a, b ) =
            a ++ " : " ++ b

        toFieldFunction : Document.VariableDefinition -> CodeGen.Declaration
        toFieldFunction var =
            let
                annotationTemplate : String
                annotationTemplate =
                    if VariableDefinition.isRequired var then
                        "${type} -> Input { missing | ${name} : ${type} } -> Input missing"

                    else
                        "${type} -> Input missing -> Input missing"
            in
            CodeGen.Declaration.function
                { name = var.name
                , annotation =
                    annotationTemplate
                        |> String.replace "${name}" var.name
                        |> String.replace "${type}" (DocumentType.toStringUnwrappingFirstMaybe schema var.type_)
                        |> CodeGen.Annotation.type_
                , arguments =
                    [ CodeGen.Argument.new "value_"
                    , CodeGen.Argument.new "(Input dict_)"
                    ]
                , expression =
                    """Input (Dict.insert "${name}" (${encoder} value_) dict_)"""
                        |> String.replace "${name}" var.name
                        |> String.replace "${encoder}" (DocumentType.toEncoderStringUnwrappingFirstMaybe schema var.type_)
                        |> CodeGen.Expression.value
                }
    in
    CodeGen.Module.new
        { name =
            [ "GraphQL"
            , "Queries"
            , Document.toName document
            , "Input"
            ]
        , exposing_ = []
        , imports =
            [ CodeGen.Import.new [ "Dict" ]
                |> CodeGen.Import.withExposing [ "Dict" ]
            , CodeGen.Import.new [ "GraphQL", "Encode" ]
            ]
                ++ extraImports
        , declarations =
            List.concat
                [ [ CodeGen.Declaration.comment [ "INPUT" ]
                  , CodeGen.Declaration.customType
                        { name = "Input missing"
                        , variants =
                            [ ( "Input"
                              , [ CodeGen.Annotation.type_ "(Dict String GraphQL.Encode.Value)" ]
                              )
                            ]
                        }
                  , CodeGen.Declaration.function
                        { name = "new"
                        , annotation =
                            if List.isEmpty requiredVariables then
                                CodeGen.Annotation.type_ "Input {}"

                            else
                                "Input { missing | ${requiredVariables} }"
                                    |> String.replace "${requiredVariables}"
                                        (requiredVariables
                                            |> List.map toRecordAnnotation
                                            |> List.map joinWithColon
                                            |> String.join ", "
                                        )
                                    |> CodeGen.Annotation.type_
                        , arguments = []
                        , expression =
                            CodeGen.Expression.value "Input Dict.empty"
                        }
                  , CodeGen.Declaration.comment [ "FIELDS" ]
                  ]
                , List.map toFieldFunction variables
                , if List.isEmpty optionalVariables then
                    []

                  else
                    [ nullFunction ]
                , [ CodeGen.Declaration.comment [ "USED INTERNALLY" ]
                  , toInternalValueFunction
                  ]
                ]
        }
        |> CodeGen.Module.withOrderedExposingList
            [ [ "Input", "new" ]
            , List.map .name variables
            , if List.isEmpty optionalVariables then
                []

              else
                [ "null" ]
            , [ "toInternalValue" ]
            ]


toInternalValueFunction : CodeGen.Declaration
toInternalValueFunction =
    CodeGen.Declaration.function
        { name = "toInternalValue"
        , annotation = CodeGen.Annotation.type_ "Input {} -> List ( String, GraphQL.Encode.Value )"
        , arguments = [ CodeGen.Argument.new "(Input dict_)" ]
        , expression = CodeGen.Expression.value "Dict.toList dict_"
        }


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
                        (let
                            { annotation } =
                                toTypeRefAnnotation
                                    fieldSelection
                                    existingTypeAliasNames
                                    fieldSchema
                         in
                         ( fieldSelection.alias
                            |> Maybe.withDefault fieldSelection.name
                         , annotation
                         )
                        )

                Nothing ->
                    Nothing

        _ ->
            Nothing


toTypeRefAnnotation :
    Document.FieldSelection
    -> Set String
    -> Schema.Field
    -> { annotation : CodeGen.Annotation, imports : Set String }
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

        ( typeAliasName, imports ) =
            case Schema.toTypeRefName field.type_ of
                "ID" ->
                    ( "GraphQL.Scalar.Id.Id"
                    , Set.singleton "GraphQL.Scalar.Id"
                    )

                _ ->
                    if Schema.isBuiltInScalarType (Schema.toTypeRefName field.type_) then
                        ( originalName, Set.empty )

                    else
                        ( originalName, Set.empty )
    in
    { annotation =
        CodeGen.Annotation.type_
            (Schema.toTypeRefAnnotation
                typeAliasName
                field.type_
            )
    , imports = imports
    }
