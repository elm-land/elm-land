module GraphQL.Enum exposing (toModule)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import GraphQL.Introspection.Schema as Schema exposing (Schema)


toModule :
    { options | schema : Schema, namespace : String }
    -> Schema.EnumType
    -> CodeGen.Module
toModule { schema, namespace } enum =
    CodeGen.Module.new
        { name = [ namespace, "Enum", enum.name ]
        , exposing_ = []
        , imports =
            [ CodeGen.Import.new [ "GraphQL", "Decode" ]
            , CodeGen.Import.new [ "GraphQL", "Encode" ]
            ]
        , declarations =
            [ CodeGen.Declaration.customType
                { name = enum.name
                , variants = List.map (\{ name } -> ( name, [] )) enum.enumValues
                }
            , CodeGen.Declaration.function
                { name = "list"
                , annotation = CodeGen.Annotation.type_ ("List " ++ enum.name)
                , arguments = []
                , expression =
                    enum.enumValues
                        |> List.map (\{ name } -> CodeGen.Expression.value name)
                        |> CodeGen.Expression.multilineList
                }
            , CodeGen.Declaration.function
                { name = "fromString"
                , annotation = CodeGen.Annotation.type_ ("String -> Maybe " ++ enum.name)
                , arguments = [ CodeGen.Argument.new "str" ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "str"
                        , branches =
                            List.concat
                                [ enum.enumValues
                                    |> List.map
                                        (\{ name } ->
                                            CodeGen.Expression.Branch
                                                ("\"" ++ name ++ "\"")
                                                []
                                                (CodeGen.Expression.value ("Just " ++ name))
                                        )
                                , [ CodeGen.Expression.Branch
                                        "_"
                                        []
                                        (CodeGen.Expression.value "Nothing")
                                  ]
                                ]
                        }
                }
            , CodeGen.Declaration.comment [ "USED INTERNALLY" ]
            , CodeGen.Declaration.function
                { name = "toString"
                , annotation = CodeGen.Annotation.type_ (enum.name ++ " -> String")
                , arguments = [ CodeGen.Argument.new "enum" ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "enum"
                        , branches =
                            enum.enumValues
                                |> List.map
                                    (\{ name } ->
                                        CodeGen.Expression.Branch
                                            name
                                            []
                                            (CodeGen.Expression.string name)
                                    )
                        }
                }
            , CodeGen.Declaration.function
                { name = "encode"
                , annotation = CodeGen.Annotation.type_ (enum.name ++ " -> GraphQL.Encode.Value")
                , arguments = [ CodeGen.Argument.new "enum" ]
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "GraphQL.Encode.enum"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "toString", CodeGen.Expression.value "toString" )
                                , ( "value", CodeGen.Expression.value "enum" )
                                ]
                            ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "decoder"
                , annotation = CodeGen.Annotation.type_ ("GraphQL.Decode.Decoder " ++ enum.name)
                , arguments = []
                , expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.value "list"
                        , CodeGen.Expression.value "List.map (\\enum -> ( toString enum, enum ))"
                        , CodeGen.Expression.value "GraphQL.Decode.enum"
                        ]
                }
            ]
        }
        |> CodeGen.Module.withOrderedExposingList
            [ [ enum.name ++ "(..)" ]
            , [ "list", "fromString" ]
            , [ "decoder", "encode" ]
            ]
