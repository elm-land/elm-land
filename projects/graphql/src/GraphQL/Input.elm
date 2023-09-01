module GraphQL.Input exposing (toInputModule)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.Introspection.Document as Document exposing (Document)
import GraphQL.Introspection.Document.Type as DocumentType
import GraphQL.Introspection.Document.VariableDefinition as VariableDefinition
import GraphQL.Introspection.Schema as Schema exposing (Schema)


toInputModule :
    { moduleName : List String
    , namespace : String
    , schema : Schema
    , variables : List Document.VariableDefinition
    }
    -> CodeGen.Module
toInputModule { moduleName, namespace, schema, variables } =
    let
        extraImports : List CodeGen.Import
        extraImports =
            variables
                |> List.concatMap
                    (\var ->
                        DocumentType.toImports
                            { namespace = namespace
                            , schema = schema
                            , type_ = var.type_
                            }
                    )

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
                    [ if Schema.isScalarType (DocumentType.toName var.type_) schema then
                        CodeGen.Argument.new "value_"

                      else
                        "(Api.Internals.Input.${type} value_)"
                            |> String.replace "${type}" (DocumentType.toName var.type_)
                            |> CodeGen.Argument.new
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
        { name = moduleName
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
