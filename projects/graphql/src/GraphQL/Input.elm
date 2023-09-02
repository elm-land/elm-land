module GraphQL.Input exposing
    ( findInputTypesUsed
    , toInputModule
    , toRootInputModule
    , toRootInternalInputModule
    )

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Document.Type as DocumentType
import GraphQL.Introspection.Document.VariableDefinition as VariableDefinition exposing (VariableDefinition)
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import GraphQL.Introspection.Schema.TypeRef as TypeRef exposing (TypeRef)
import Set exposing (Set)


toRootInputModule : { namespace : String, schema : Schema, inputTypes : List Schema.InputObjectType } -> CodeGen.Module
toRootInputModule { namespace, schema, inputTypes } =
    let
        toTypeForInputObject : Schema.InputObjectType -> CodeGen.Declaration
        toTypeForInputObject input =
            CodeGen.Declaration.typeAlias
                { name = input.name
                , annotation =
                    CodeGen.Annotation.type_
                        (String.join "."
                            [ namespace
                            , "Internals"
                            , "Input"
                            , input.name
                            ]
                            ++ " {}"
                        )
                }
    in
    CodeGen.Module.new
        { name = [ namespace, "Input" ]
        , exposing_ = [ ".." ]
        , imports =
            [ CodeGen.Import.new [ namespace, "Internals", "Input" ]
            ]
        , declarations = List.map toTypeForInputObject inputTypes
        }


toRootInternalInputModule : { namespace : String, schema : Schema, inputTypes : List Schema.InputObjectType } -> CodeGen.Module
toRootInternalInputModule { namespace, schema, inputTypes } =
    let
        toTypeForInputObject : Schema.InputObjectType -> CodeGen.Declaration
        toTypeForInputObject input =
            CodeGen.Declaration.customType
                { name = input.name ++ " missing"
                , variants =
                    [ ( input.name, [ CodeGen.Annotation.type_ "(Dict String GraphQL.Encode.Value)" ] )
                    ]
                }
    in
    CodeGen.Module.new
        { name = [ namespace, "Internals", "Input" ]
        , exposing_ = [ ".." ]
        , imports =
            [ CodeGen.Import.new [ "Dict" ]
                |> CodeGen.Import.withExposing [ "Dict" ]
            , CodeGen.Import.new [ "GraphQL", "Encode" ]
            ]
        , declarations = List.map toTypeForInputObject inputTypes
        }


findInputTypesUsed :
    { schema : Schema
    , document : Document
    }
    -> Set String
findInputTypesUsed options =
    let
        collectFromInputType : Schema.InputValue -> Set String -> Set String
        collectFromInputType inputValue set =
            collectWithName
                (TypeRef.toName inputValue.type_)
                set

        collectFromVariableDefinition : VariableDefinition -> Set String -> Set String
        collectFromVariableDefinition var set =
            collectWithName (DocumentType.toName var.type_)
                set

        collectWithName : String -> Set String -> Set String
        collectWithName name set =
            case Schema.findInputObjectTypeWithName name options.schema of
                Just input ->
                    Set.singleton name
                        |> Set.union (findNestedInputTypes input)
                        |> Set.union set

                Nothing ->
                    set

        findNestedInputTypes : Schema.InputObjectType -> Set String
        findNestedInputTypes input =
            input.inputFields
                |> List.foldl collectFromInputType Set.empty
    in
    Document.toVariables options.document
        |> List.foldl collectFromVariableDefinition Set.empty


toInputModule :
    { isInputObject : Bool
    , moduleName : List String
    , namespace : String
    , schema : Schema
    , inputTypeName : String
    , variables : List variable
    , isRequired : variable -> Bool
    , toVarName : variable -> String
    , toTypeNameUnwrappingFirstMaybe : variable -> String
    , toTypeName : variable -> String
    , toEncoderString : variable -> String
    }
    -> CodeGen.Module
toInputModule { isInputObject, inputTypeName, moduleName, namespace, schema, variables, toEncoderString, toTypeName, toTypeNameUnwrappingFirstMaybe, toVarName, isRequired } =
    let
        extraImports : List CodeGen.Import
        extraImports =
            variables
                |> List.concatMap
                    (\var ->
                        DocumentType.toImports
                            { namespace = namespace
                            , schema = schema
                            , name = var |> toTypeName
                            }
                    )

        requiredVariables : List variable
        requiredVariables =
            List.filter isRequired variables

        optionalVariables : List variable
        optionalVariables =
            List.filter (isRequired >> not) variables

        nullFunction : CodeGen.Declaration
        nullFunction =
            CodeGen.Declaration.function
                { name = "null"
                , annotation =
                    optionalVariables
                        |> List.map
                            (\var ->
                                ( toVarName var
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
            variable
            -> ( String, CodeGen.Expression )
        toRecordNullValue var =
            ( toVarName var
            , """\\(Input dict_) -> Input (Dict.insert "${name}" GraphQL.Encode.null dict_)"""
                |> String.replace "${name}" (toVarName var)
                |> CodeGen.Expression.value
            )

        toRecordAnnotation : variable -> ( String, String )
        toRecordAnnotation var =
            ( toVarName var
            , var
                |> toTypeNameUnwrappingFirstMaybe
            )

        joinWithColon : ( String, String ) -> String
        joinWithColon ( a, b ) =
            a ++ " : " ++ b

        toFieldFunction : variable -> CodeGen.Declaration
        toFieldFunction var =
            let
                typeName : String
                typeName =
                    var |> toTypeName

                annotationTemplate : String
                annotationTemplate =
                    if isRequired var then
                        "${type} -> Input { missing | ${name} : ${type} } -> Input missing"

                    else
                        "${type} -> Input missing -> Input missing"
            in
            CodeGen.Declaration.function
                { name = toVarName var
                , annotation =
                    annotationTemplate
                        |> String.replace "${name}" (toVarName var)
                        |> String.replace "${type}" (toTypeNameUnwrappingFirstMaybe var)
                        |> CodeGen.Annotation.type_
                , arguments =
                    [ if Schema.isScalarType typeName schema then
                        CodeGen.Argument.new "value_"

                      else
                        "(Api.Internals.Input.${type} value_)"
                            |> String.replace "${type}" typeName
                            |> CodeGen.Argument.new
                    , "(${variant} dict_)"
                        |> String.replace "${variant}" variant
                        |> CodeGen.Argument.new
                    ]
                , expression =
                    """${variant} (Dict.insert "${name}" (${encoder} value_) dict_)"""
                        |> String.replace "${variant}" variant
                        |> String.replace "${name}" (toVarName var)
                        |> String.replace "${encoder}" (toEncoderString var)
                        |> CodeGen.Expression.value
                }

        variant : String
        variant =
            if isInputObject then
                "Api.Internals.Input." ++ inputTypeName

            else
                "Input"
    in
    CodeGen.Module.new
        { name = moduleName
        , exposing_ = []
        , imports =
            List.concat
                [ if isInputObject then
                    [ CodeGen.Import.new [ namespace, "Internals", "Input" ] ]

                  else
                    []
                , [ CodeGen.Import.new [ "Dict" ]
                        |> CodeGen.Import.withExposing [ "Dict" ]
                  , CodeGen.Import.new [ "GraphQL", "Encode" ]
                  ]
                , extraImports
                ]
        , declarations =
            List.concat
                [ [ CodeGen.Declaration.comment [ "INPUT" ]
                  , if isInputObject then
                        CodeGen.Declaration.typeAlias
                            { name = "Input missing"
                            , annotation = CodeGen.Annotation.type_ (variant ++ " missing")
                            }

                    else
                        CodeGen.Declaration.customType
                            { name = "Input missing"
                            , variants =
                                [ ( variant
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
                            CodeGen.Expression.value
                                ("${variant} Dict.empty"
                                    |> String.replace "${variant}" variant
                                )
                        }
                  , CodeGen.Declaration.comment [ "FIELDS" ]
                  ]
                , List.map toFieldFunction variables
                , if List.isEmpty optionalVariables then
                    []

                  else
                    [ nullFunction ]
                , if isInputObject then
                    []

                  else
                    [ CodeGen.Declaration.comment [ "USED INTERNALLY" ]
                    , toInternalValueFunction
                    ]
                ]
        }
        |> CodeGen.Module.withOrderedExposingList
            [ [ "Input", "new" ]
            , List.map toVarName variables
            , if List.isEmpty optionalVariables then
                []

              else
                [ "null" ]
            , if isInputObject then
                []

              else
                [ "toInternalValue" ]
            ]


toInternalValueFunction : CodeGen.Declaration
toInternalValueFunction =
    CodeGen.Declaration.function
        { name = "toInternalValue"
        , annotation = CodeGen.Annotation.type_ "Input {} -> List ( String, GraphQL.Encode.Value )"
        , arguments = [ CodeGen.Argument.new "(Input dict_)" ]
        , expression = CodeGen.Expression.value "Dict.toList dict_"
        }
