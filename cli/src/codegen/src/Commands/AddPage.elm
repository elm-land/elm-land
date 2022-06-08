module Commands.AddPage exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Extras.String
import Filepath exposing (Filepath)
import Json.Decode


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            [ newPageModule data ]

        Err _ ->
            []


type alias Data =
    { kind : PageKind
    , url : String
    , filepath : Filepath
    }


type PageKind
    = Static
    | Sandbox
    | Element
    | New


newPageModule : Data -> CodeGen.Module
newPageModule { url, filepath, kind } =
    case kind of
        Static ->
            newStaticPageModule filepath url

        Sandbox ->
            newSandboxPageModule filepath url

        Element ->
            newElementPageModule filepath url

        New ->
            newStaticPageModule filepath url


newStaticPageModule : Filepath -> String -> CodeGen.Module
newStaticPageModule filepath url =
    let
        moduleName : String
        moduleName =
            Filepath.toPageModuleName filepath

        staticPageFn : CodeGen.Declaration
        staticPageFn =
            if Filepath.hasDynamicParameters filepath then
                CodeGen.Declaration.function
                    { name = "page"
                    , annotation =
                        CodeGen.Annotation.function
                            [ Filepath.toParamsRecordAnnotation filepath
                            , CodeGen.Annotation.type_ "View msg"
                            ]
                    , arguments = [ CodeGen.Argument.new "params" ]
                    , expression =
                        viewExpressionWithContent
                            { title = moduleName
                            , expression =
                                CodeGen.Expression.parens
                                    (Filepath.toList filepath
                                        |> List.map
                                            (\piece ->
                                                if String.endsWith "_" piece then
                                                    CodeGen.Expression.value
                                                        ("params." ++ Extras.String.fromPascalCaseToCamelCase (String.dropRight 1 piece))

                                                else
                                                    CodeGen.Expression.string
                                                        ("/" ++ Extras.String.fromPascalCaseToKebabCase piece ++ "/")
                                            )
                                        |> List.intersperse (CodeGen.Expression.operator "++")
                                    )
                            }
                    }

            else
                CodeGen.Declaration.function
                    { name = "page"
                    , annotation = CodeGen.Annotation.type_ "View msg"
                    , arguments = []
                    , expression =
                        viewExpressionWithContent
                            { title = moduleName
                            , expression = CodeGen.Expression.string url
                            }
                    }
    in
    CodeGen.Module.new
        { name = "Pages" :: Filepath.toList filepath
        , exposing_ = [ "page" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ staticPageFn
            ]
        }


newSandboxPageModule : Filepath -> String -> CodeGen.Module
newSandboxPageModule filepath url =
    let
        pageFunctionDeclaration : CodeGen.Declaration
        pageFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "page"
                , annotation =
                    if Filepath.hasDynamicParameters filepath then
                        CodeGen.Annotation.function
                            [ Filepath.toParamsRecordAnnotation filepath
                            , CodeGen.Annotation.type_ "Page Model Msg"
                            ]

                    else
                        CodeGen.Annotation.type_ "Page Model Msg"
                , arguments =
                    if Filepath.hasDynamicParameters filepath then
                        [ CodeGen.Argument.new "params" ]

                    else
                        []
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "ElmLand.Page.sandbox"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "init", CodeGen.Expression.value "init" )
                                , ( "update", CodeGen.Expression.value "update" )
                                , ( "view", CodeGen.Expression.value "view" )
                                ]
                            ]
                        }
                }

        modelTypeDeclaration : CodeGen.Declaration
        modelTypeDeclaration =
            CodeGen.Declaration.typeAlias
                { name = "Model"
                , annotation = CodeGen.Annotation.multilineRecord []
                }

        initFunctionDeclaration : CodeGen.Declaration
        initFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "init"
                , annotation = CodeGen.Annotation.type_ "Model"
                , arguments = []
                , expression =
                    CodeGen.Expression.record []
                }

        msgTypeDeclaration : CodeGen.Declaration
        msgTypeDeclaration =
            CodeGen.Declaration.customType
                { name = "Msg"
                , variants =
                    [ ( "ExampleMsgReplaceMe", [] )
                    ]
                }

        updateFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "update"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Msg"
                        , CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "Model"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "msg"
                    , CodeGen.Argument.new "model"
                    ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "msg"
                        , branches =
                            [ { name = "ExampleMsgReplaceMe"
                              , arguments = []
                              , expression = CodeGen.Expression.value "model"
                              }
                            ]
                        }
                }

        viewFunctionDeclaration : CodeGen.Declaration
        viewFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "view"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "View Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression =
                    viewExpressionWithContent
                        { title = Filepath.toPageModuleName filepath
                        , expression = CodeGen.Expression.string url
                        }
                }
    in
    CodeGen.Module.new
        { name = "Pages" :: Filepath.toList filepath
        , exposing_ = [ "Model", "Msg", "page" ]
        , imports =
            [ CodeGen.Import.new [ "ElmLand", "Page" ]
                |> CodeGen.Import.withExposing [ "Page" ]
            , CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ pageFunctionDeclaration
            , CodeGen.Declaration.comment [ "INIT" ]
            , modelTypeDeclaration
            , initFunctionDeclaration
            , CodeGen.Declaration.comment [ "UPDATE" ]
            , msgTypeDeclaration
            , updateFunctionDeclaration
            , CodeGen.Declaration.comment [ "VIEW" ]
            , viewFunctionDeclaration
            ]
        }


newElementPageModule : Filepath -> String -> CodeGen.Module
newElementPageModule filepath url =
    let
        pageFunctionDeclaration : CodeGen.Declaration
        pageFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "page"
                , annotation =
                    if Filepath.hasDynamicParameters filepath then
                        CodeGen.Annotation.function
                            [ Filepath.toParamsRecordAnnotation filepath
                            , CodeGen.Annotation.type_ "Page Model Msg"
                            ]

                    else
                        CodeGen.Annotation.type_ "Page Model Msg"
                , arguments =
                    if Filepath.hasDynamicParameters filepath then
                        [ CodeGen.Argument.new "params" ]

                    else
                        []
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "ElmLand.Page.element"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "init", CodeGen.Expression.value "init" )
                                , ( "update", CodeGen.Expression.value "update" )
                                , ( "subscriptions", CodeGen.Expression.value "subscriptions" )
                                , ( "view", CodeGen.Expression.value "view" )
                                ]
                            ]
                        }
                }

        modelTypeDeclaration : CodeGen.Declaration
        modelTypeDeclaration =
            CodeGen.Declaration.typeAlias
                { name = "Model"
                , annotation = CodeGen.Annotation.multilineRecord []
                }

        initFunctionDeclaration : CodeGen.Declaration
        initFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "init"
                , annotation = CodeGen.Annotation.type_ "( Model, Cmd Msg )"
                , arguments = []
                , expression =
                    CodeGen.Expression.multilineTuple
                        [ CodeGen.Expression.record []
                        , CodeGen.Expression.value "Cmd.none"
                        ]
                }

        msgTypeDeclaration : CodeGen.Declaration
        msgTypeDeclaration =
            CodeGen.Declaration.customType
                { name = "Msg"
                , variants =
                    [ ( "ExampleMsgReplaceMe", [] )
                    ]
                }

        updateFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "update"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Msg"
                        , CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "( Model, Cmd Msg )"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "msg"
                    , CodeGen.Argument.new "model"
                    ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "msg"
                        , branches =
                            [ { name = "ExampleMsgReplaceMe"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "model"
                                        , CodeGen.Expression.value "Cmd.none"
                                        ]
                              }
                            ]
                        }
                }

        subscriptionsFunctionDeclaration : CodeGen.Declaration
        subscriptionsFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "subscriptions"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "Sub Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = CodeGen.Expression.value "Sub.none"
                }

        viewFunctionDeclaration : CodeGen.Declaration
        viewFunctionDeclaration =
            CodeGen.Declaration.function
                { name = "view"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "View Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression =
                    viewExpressionWithContent
                        { title = Filepath.toPageModuleName filepath
                        , expression = CodeGen.Expression.string url
                        }
                }
    in
    CodeGen.Module.new
        { name = "Pages" :: Filepath.toList filepath
        , exposing_ = [ "Model", "Msg", "page" ]
        , imports =
            [ CodeGen.Import.new [ "ElmLand", "Page" ]
                |> CodeGen.Import.withExposing [ "Page" ]
            , CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ pageFunctionDeclaration
            , CodeGen.Declaration.comment [ "INIT" ]
            , modelTypeDeclaration
            , initFunctionDeclaration
            , CodeGen.Declaration.comment [ "UPDATE" ]
            , msgTypeDeclaration
            , updateFunctionDeclaration
            , CodeGen.Declaration.comment [ "SUBSCRIPTIONS" ]
            , subscriptionsFunctionDeclaration
            , CodeGen.Declaration.comment [ "VIEW" ]
            , viewFunctionDeclaration
            ]
        }


viewExpressionWithContent : { title : String, expression : CodeGen.Expression } -> CodeGen.Expression
viewExpressionWithContent options =
    CodeGen.Expression.multilineRecord
        [ ( "title", CodeGen.Expression.string options.title )
        , ( "body"
          , CodeGen.Expression.list
                [ CodeGen.Expression.function
                    { name = "Html.text"
                    , arguments =
                        [ options.expression
                        ]
                    }
                ]
          )
        ]



-- DECODING


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map3 Data
        (Json.Decode.field "kind" pageKindDecoder)
        (Json.Decode.field "url" Json.Decode.string)
        (Json.Decode.field "filepath" Filepath.decoder)


pageKindDecoder : Json.Decode.Decoder PageKind
pageKindDecoder =
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case str of
                    "static" ->
                        Json.Decode.succeed Static

                    "sandbox" ->
                        Json.Decode.succeed Sandbox

                    "element" ->
                        Json.Decode.succeed Element

                    _ ->
                        Json.Decode.succeed New
            )
