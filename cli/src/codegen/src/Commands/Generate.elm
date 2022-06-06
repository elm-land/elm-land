module Commands.Generate exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Filepath exposing (Filepath)
import Json.Decode
import PageFile exposing (PageFile)


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            List.concat
                [ [ mainElmModule data
                  , routeElmModule data
                  , notFoundModule
                  ]
                , if List.isEmpty data.layouts then
                    []

                  else
                    [ elmLandLayoutsElmModule data ]
                ]

        Err _ ->
            []


mainElmModule : Data -> CodeGen.Module
mainElmModule data =
    CodeGen.Module.new
        { name = [ "Main" ]
        , exposing_ = [ "main" ]
        , imports =
            List.concat
                [ [ CodeGen.Import.new [ "Browser" ]
                  , CodeGen.Import.new [ "Browser", "Navigation" ]
                  , CodeGen.Import.new [ "ElmLand", "Page" ]
                  , CodeGen.Import.new [ "Html" ]
                        |> CodeGen.Import.withExposing [ "Html" ]
                  , CodeGen.Import.new [ "Json", "Decode" ]
                  ]
                , data.layouts
                    |> List.map Filepath.toList
                    |> List.map (\pieces -> "Layouts" :: pieces)
                    |> List.map CodeGen.Import.new
                , data.pages
                    |> List.map PageFile.toFilepath
                    |> List.map Filepath.toList
                    |> List.map (\pieces -> "Pages" :: pieces)
                    |> List.map CodeGen.Import.new
                , [ CodeGen.Import.new [ "Pages", "NotFound_" ]
                  , CodeGen.Import.new [ "Route" ]
                  , CodeGen.Import.new [ "Url" ]
                        |> CodeGen.Import.withExposing [ "Url" ]
                  ]
                ]
        , declarations =
            [ CodeGen.Declaration.typeAlias
                { name = "Flags"
                , annotation = CodeGen.Annotation.type_ "Json.Decode.Value"
                }
            , CodeGen.Declaration.function
                { name = "main"
                , annotation = CodeGen.Annotation.type_ "Program Flags Model Msg"
                , arguments = []
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "Browser.application"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "init", CodeGen.Expression.value "init" )
                                , ( "update", CodeGen.Expression.value "update" )
                                , ( "view", CodeGen.Expression.value "view" )
                                , ( "subscriptions", CodeGen.Expression.value "subscriptions" )
                                , ( "onUrlChange", CodeGen.Expression.value "UrlChanged" )
                                , ( "onUrlRequest", CodeGen.Expression.value "UrlRequested" )
                                ]
                            ]
                        }
                }
            , CodeGen.Declaration.comment [ "INIT" ]
            , CodeGen.Declaration.typeAlias
                { name = "Model"
                , annotation =
                    CodeGen.Annotation.multilineRecord
                        [ ( "flags", CodeGen.Annotation.type_ "Flags" )
                        , ( "key", CodeGen.Annotation.type_ "Browser.Navigation.Key" )
                        , ( "url", CodeGen.Annotation.type_ "Url" )
                        , ( "page", CodeGen.Annotation.type_ "PageModel" )
                        ]
                }
            , CodeGen.Declaration.customType
                { name = "PageModel"
                , variants = toPageModelCustomType data.pages
                }
            , CodeGen.Declaration.function
                { name = "init"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Flags"
                        , CodeGen.Annotation.type_ "Url"
                        , CodeGen.Annotation.type_ "Browser.Navigation.Key"
                        , CodeGen.Annotation.type_ "( Model, Cmd Msg )"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "flags"
                    , CodeGen.Argument.new "url"
                    , CodeGen.Argument.new "key"
                    ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                              , annotation = Nothing
                              , expression = toInitPageCaseExpression data.pages
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.multilineTuple
                                [ CodeGen.Expression.multilineRecord
                                    [ ( "flags", CodeGen.Expression.value "flags" )
                                    , ( "url", CodeGen.Expression.value "url" )
                                    , ( "key", CodeGen.Expression.value "key" )
                                    , ( "page", CodeGen.Expression.value "pageModel" )
                                    ]
                                , CodeGen.Expression.function
                                    { name = "Cmd.map"
                                    , arguments =
                                        [ CodeGen.Expression.value "PageSentMsg"
                                        , CodeGen.Expression.value "pageCmd"
                                        ]
                                    }
                                ]
                        }
                }
            , CodeGen.Declaration.comment [ "UPDATE" ]
            , CodeGen.Declaration.customType
                { name = "Msg"
                , variants =
                    [ ( "UrlRequested", [ CodeGen.Annotation.type_ "Browser.UrlRequest" ] )
                    , ( "UrlChanged", [ CodeGen.Annotation.type_ "Url" ] )
                    , ( "PageSentMsg", [ CodeGen.Annotation.type_ "PageMsg" ] )
                    ]
                }
            , CodeGen.Declaration.customType
                { name = "PageMsg"
                , variants = toPageMsgCustomType data.pages
                }
            , CodeGen.Declaration.function
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
                            [ { name = "UrlRequested"
                              , arguments = [ CodeGen.Argument.new "(Browser.Internal url)" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "model"
                                        , CodeGen.Expression.function
                                            { name = "Browser.Navigation.pushUrl"
                                            , arguments =
                                                [ CodeGen.Expression.value "model.key"
                                                , CodeGen.Expression.value "(Url.toString url)"
                                                ]
                                            }
                                        ]
                              }
                            , { name = "UrlRequested"
                              , arguments = [ CodeGen.Argument.new "(Browser.External url)" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "model"
                                        , CodeGen.Expression.function
                                            { name = "Browser.Navigation.load"
                                            , arguments =
                                                [ CodeGen.Expression.value "url"
                                                ]
                                            }
                                        ]
                              }
                            , { name = "UrlChanged"
                              , arguments = [ CodeGen.Argument.new "url" ]
                              , expression =
                                    CodeGen.Expression.letIn
                                        { let_ =
                                            [ { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                                              , annotation = Nothing
                                              , expression = toInitPageCaseExpression data.pages
                                              }
                                            ]
                                        , in_ =
                                            CodeGen.Expression.multilineTuple
                                                [ CodeGen.Expression.recordUpdate
                                                    { value = "model"
                                                    , fields =
                                                        [ ( "url", CodeGen.Expression.value "url" )
                                                        , ( "page", CodeGen.Expression.value "pageModel" )
                                                        ]
                                                    }
                                                , CodeGen.Expression.function
                                                    { name = "Cmd.map"
                                                    , arguments =
                                                        [ CodeGen.Expression.value "PageSentMsg"
                                                        , CodeGen.Expression.value "pageCmd"
                                                        ]
                                                    }
                                                ]
                                        }
                              }
                            , { name = "PageSentMsg"
                              , arguments = [ CodeGen.Argument.new "pageMsg" ]
                              , expression =
                                    CodeGen.Expression.letIn
                                        { let_ =
                                            [ { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                                              , annotation = Nothing
                                              , expression =
                                                    CodeGen.Expression.function
                                                        { name = "updateFromPage"
                                                        , arguments =
                                                            [ CodeGen.Expression.value "pageMsg"
                                                            , CodeGen.Expression.value "model.page"
                                                            ]
                                                        }
                                              }
                                            ]
                                        , in_ =
                                            CodeGen.Expression.multilineTuple
                                                [ CodeGen.Expression.recordUpdate
                                                    { value = "model"
                                                    , fields =
                                                        [ ( "page", CodeGen.Expression.value "pageModel" )
                                                        ]
                                                    }
                                                , CodeGen.Expression.function
                                                    { name = "Cmd.map"
                                                    , arguments =
                                                        [ CodeGen.Expression.value "PageSentMsg"
                                                        , CodeGen.Expression.value "pageCmd"
                                                        ]
                                                    }
                                                ]
                                        }
                              }
                            ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "updateFromPage"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "PageMsg"
                        , CodeGen.Annotation.type_ "PageModel"
                        , CodeGen.Annotation.type_ "( PageModel, Cmd PageMsg )"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "msg"
                    , CodeGen.Argument.new "model"
                    ]
                , expression = toUpdatePageCaseExpression data.pages
                }
            , CodeGen.Declaration.function
                { name = "subscriptions"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "Sub Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = toSubscriptionPageCaseExpression data.pages
                }
            , CodeGen.Declaration.comment [ "VIEW" ]
            , CodeGen.Declaration.function
                { name = "view"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "Browser.Document Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression =
                    CodeGen.Expression.multilineRecord
                        [ ( "title", CodeGen.Expression.string "App" )
                        , ( "body"
                          , CodeGen.Expression.list
                                [ CodeGen.Expression.function
                                    { name = "viewPage"
                                    , arguments =
                                        [ CodeGen.Expression.value "model"
                                        ]
                                    }
                                ]
                          )
                        ]
                }
            , CodeGen.Declaration.function
                { name = "viewPage"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "Html Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = toViewPageCaseExpression data.pages
                }
            ]
        }


toPageMsgCustomType : List PageFile -> List ( String, List CodeGen.Annotation )
toPageMsgCustomType pages =
    let
        toCustomType : PageFile -> ( String, List CodeGen.Annotation.Annotation )
        toCustomType page =
            let
                filepath : Filepath
                filepath =
                    PageFile.toFilepath page
            in
            ( "PageMsg" ++ Filepath.toRouteVariantName filepath
            , if PageFile.isElmLandPage page then
                [ CodeGen.Annotation.type_ (Filepath.toPageModuleName filepath ++ ".Msg")
                ]

              else
                []
            )
    in
    List.concat
        [ List.map toCustomType pages
        , [ ( "PageMsgNotFound_", [] ) ]
        ]


toPageModelCustomType : List PageFile -> List ( String, List CodeGen.Annotation )
toPageModelCustomType pages =
    let
        toCustomType : PageFile -> ( String, List CodeGen.Annotation.Annotation )
        toCustomType page =
            let
                filepath : Filepath
                filepath =
                    PageFile.toFilepath page
            in
            ( "PageModel" ++ Filepath.toRouteVariantName filepath
            , List.concat
                [ if Filepath.hasDynamicParameters filepath then
                    [ Filepath.toParamsRecordAnnotation filepath ]

                  else
                    []
                , if PageFile.isElmLandPage page then
                    [ CodeGen.Annotation.type_ (Filepath.toPageModuleName filepath ++ ".Model")
                    ]

                  else
                    []
                ]
            )
    in
    List.concat
        [ List.map toCustomType pages
        , [ ( "PageModelNotFound_", [] ) ]
        ]


toViewPageCaseExpression : List PageFile -> CodeGen.Expression
toViewPageCaseExpression pages =
    let
        conditionallyWrapInLayout : PageFile -> CodeGen.Expression -> CodeGen.Expression
        conditionallyWrapInLayout page pageExpression =
            case PageFile.toLayoutName page of
                Just layoutName ->
                    CodeGen.Expression.multilineFunction
                        { name = "Layouts." ++ layoutName ++ ".layout"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "page", pageExpression )
                                ]
                            ]
                        }

                Nothing ->
                    pageExpression

        toViewBranch : PageFile -> CodeGen.Expression.Branch
        toViewBranch page =
            let
                filepath : Filepath
                filepath =
                    PageFile.toFilepath page
            in
            if PageFile.isElmLandPage page then
                toBranchForElmLandPage page filepath

            else
                toBranchForStaticPage page filepath

        toBranchForElmLandPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForElmLandPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                conditionallyWrapInLayout page
                    (toPageModelMapper
                        { filepath = filepath
                        , function = "view"
                        , mapper = "Html.map"
                        }
                    )
            }

        toBranchForStaticPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForStaticPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                conditionallyWrapInLayout page
                    (callPageFunction filepath)
            }
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "model.page"
        , branches =
            List.concat
                [ List.map toViewBranch pages
                , [ { name = "PageModelNotFound_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Pages.NotFound_.page"
                    }
                  ]
                ]
        }


toPageModelArgs : PageFile -> Filepath -> List CodeGen.Argument.Argument
toPageModelArgs page filepath =
    List.concat
        [ if Filepath.hasDynamicParameters filepath then
            [ CodeGen.Argument.new "params" ]

          else
            []
        , if PageFile.isElmLandPage page then
            [ CodeGen.Argument.new "pageModel" ]

          else
            []
        ]


toUpdatePageCaseExpression : List PageFile -> CodeGen.Expression
toUpdatePageCaseExpression pages =
    let
        defaultCaseBranch : CodeGen.Expression.Branch
        defaultCaseBranch =
            { name = "_"
            , arguments = []
            , expression =
                CodeGen.Expression.multilineTuple
                    [ CodeGen.Expression.value "model"
                    , CodeGen.Expression.value "Cmd.none"
                    ]
            }

        toBranchForStaticPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForStaticPage page filepath =
            { name =
                "( PageMsg{{name}}, PageModel{{name}} {{args}} )"
                    |> String.replace "{{name}}" (Filepath.toRouteVariantName filepath)
                    |> String.replace "{{args}}"
                        (toPageModelArgs page filepath
                            |> List.map CodeGen.Argument.toString
                            |> String.join " "
                        )
            , arguments = []
            , expression =
                CodeGen.Expression.multilineTuple
                    [ CodeGen.Expression.value "model"
                    , CodeGen.Expression.value "Cmd.none"
                    ]
            }

        toBranchForElmLandPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForElmLandPage page filepath =
            { name =
                "( PageMsg{{name}} pageMsg, PageModel{{name}} {{args}} )"
                    |> String.replace "{{name}}" (Filepath.toRouteVariantName filepath)
                    |> String.replace "{{args}}"
                        (toPageModelArgs page filepath
                            |> List.map CodeGen.Argument.toString
                            |> String.join " "
                        )
            , arguments = []
            , expression =
                CodeGen.Expression.multilineFunction
                    { name = "Tuple.mapBoth"
                    , arguments =
                        [ pageModelConstructor filepath
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Cmd.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("PageMsg" ++ Filepath.toRouteVariantName filepath)
                                    ]
                                }
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "ElmLand.Page.update"
                                , arguments =
                                    [ callPageFunction filepath
                                    , CodeGen.Expression.value "pageMsg"
                                    , CodeGen.Expression.value "pageModel"
                                    ]
                                }
                            ]
                        ]
                    }
            }

        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            let
                filepath : Filepath
                filepath =
                    PageFile.toFilepath page
            in
            if PageFile.isElmLandPage page then
                toBranchForElmLandPage page filepath

            else
                toBranchForStaticPage page filepath
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "( msg, model )"
        , branches =
            List.concat
                [ List.map toBranch pages
                , [ { name = "( PageMsgNotFound_, PageModelNotFound_ )"
                    , arguments = []
                    , expression =
                        CodeGen.Expression.multilineTuple
                            [ CodeGen.Expression.value "model"
                            , CodeGen.Expression.value "Cmd.none"
                            ]
                    }
                  , defaultCaseBranch
                  ]
                ]
        }


toSubscriptionPageCaseExpression : List PageFile -> CodeGen.Expression.Expression
toSubscriptionPageCaseExpression pages =
    let
        toBranchForStaticPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForStaticPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression = CodeGen.Expression.value "Sub.none"
            }

        toBranchForElmLandPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForElmLandPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                toPageModelMapper
                    { filepath = filepath
                    , function = "subscriptions"
                    , mapper = "Sub.map"
                    }
            }

        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            let
                filepath : Filepath
                filepath =
                    PageFile.toFilepath page
            in
            if PageFile.isElmLandPage page then
                toBranchForElmLandPage page filepath

            else
                toBranchForStaticPage page filepath
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "model.page"
        , branches =
            List.concat
                [ List.map toBranch pages
                , [ { name = "PageModelNotFound_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  ]
                ]
        }


toInitPageCaseExpression : List PageFile -> CodeGen.Expression.Expression
toInitPageCaseExpression pages =
    let
        toBranchExpressionForStaticPage : Filepath -> CodeGen.Expression
        toBranchExpressionForStaticPage filepath =
            CodeGen.Expression.multilineTuple
                [ pageModelConstructor filepath
                , CodeGen.Expression.value "Cmd.none"
                ]

        toBranchExpressionForElmLandPage : Filepath -> CodeGen.Expression
        toBranchExpressionForElmLandPage filepath =
            CodeGen.Expression.multilineFunction
                { name = "Tuple.mapBoth"
                , arguments =
                    [ pageModelConstructor filepath
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Cmd.map"
                            , arguments =
                                [ CodeGen.Expression.value ("PageMsg" ++ Filepath.toRouteVariantName filepath)
                                ]
                            }
                        ]
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "ElmLand.Page.init"
                            , arguments =
                                [ callPageFunction filepath
                                ]
                            }
                        ]
                    ]
                }

        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            let
                filepath : Filepath
                filepath =
                    PageFile.toFilepath page

                branchExpression =
                    if PageFile.isElmLandPage page then
                        toBranchExpressionForElmLandPage filepath

                    else
                        toBranchExpressionForStaticPage filepath
            in
            if Filepath.hasDynamicParameters filepath then
                { name = "Route." ++ Filepath.toRouteVariantName filepath
                , arguments = [ CodeGen.Argument.new "params" ]
                , expression = branchExpression
                }

            else
                { name = "Route." ++ Filepath.toRouteVariantName filepath
                , arguments = []
                , expression = branchExpression
                }
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "Route.fromUrl url"
        , branches =
            List.concat
                [ List.map toBranch pages
                , [ { name = "Route.NotFound_"
                    , arguments = []
                    , expression =
                        CodeGen.Expression.multilineTuple
                            [ CodeGen.Expression.value "PageModelNotFound_"
                            , CodeGen.Expression.value "Cmd.none"
                            ]
                    }
                  ]
                ]
        }


pageModelConstructor : Filepath -> CodeGen.Expression
pageModelConstructor filepath =
    if Filepath.hasDynamicParameters filepath then
        CodeGen.Expression.parens
            [ CodeGen.Expression.function
                { name = "PageModel" ++ Filepath.toRouteVariantName filepath
                , arguments = [ CodeGen.Expression.value "params" ]
                }
            ]

    else
        CodeGen.Expression.value ("PageModel" ++ Filepath.toRouteVariantName filepath)


callPageFunction : Filepath -> CodeGen.Expression
callPageFunction filepath =
    if Filepath.hasDynamicParameters filepath then
        CodeGen.Expression.parens
            [ CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")
            , CodeGen.Expression.value "params"
            ]

    else
        CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")


toPageModelMapper :
    { filepath : Filepath
    , function : String
    , mapper : String
    }
    -> CodeGen.Expression
toPageModelMapper options =
    let
        pageModuleName =
            Filepath.toPageModuleName options.filepath

        routeVariantName =
            Filepath.toRouteVariantName options.filepath
    in
    CodeGen.Expression.pipeline
        [ CodeGen.Expression.function
            { name = "ElmLand.Page." ++ options.function
            , arguments =
                [ if Filepath.hasDynamicParameters options.filepath then
                    CodeGen.Expression.parens
                        [ CodeGen.Expression.value (pageModuleName ++ ".page")
                        , CodeGen.Expression.value "params"
                        ]

                  else
                    CodeGen.Expression.value (pageModuleName ++ ".page")
                , CodeGen.Expression.value "pageModel"
                ]
            }
        , CodeGen.Expression.function
            { name = options.mapper
            , arguments = [ CodeGen.Expression.value ("PageMsg" ++ routeVariantName) ]
            }
        , CodeGen.Expression.function
            { name = options.mapper
            , arguments = [ CodeGen.Expression.value "PageSentMsg" ]
            }
        ]


routeElmModule : Data -> CodeGen.Module
routeElmModule data =
    CodeGen.Module.new
        { name = [ "Route" ]
        , exposing_ = [ "Route(..)", "fromUrl" ]
        , imports =
            [ CodeGen.Import.new [ "Url" ]
                |> CodeGen.Import.withExposing [ "Url" ]
            , CodeGen.Import.new [ "Url.Parser" ]
                |> CodeGen.Import.withExposing [ "(</>)" ]
            ]
        , declarations =
            [ CodeGen.Declaration.customType
                { name = "Route"
                , variants =
                    List.concat
                        [ data.pages
                            |> List.map PageFile.toFilepath
                            |> List.map Filepath.toRouteVariant
                        , [ ( "NotFound_", [] ) ]
                        ]
                }
            , CodeGen.Declaration.function
                { name = "fromUrl"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Url"
                        , CodeGen.Annotation.type_ "Route"
                        ]
                , arguments = [ CodeGen.Argument.new "url" ]
                , expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.function
                            { name = "Url.Parser.parse"
                            , arguments =
                                [ CodeGen.Expression.value "parser"
                                , CodeGen.Expression.value "url"
                                ]
                            }
                        , CodeGen.Expression.function
                            { name = "Maybe.withDefault"
                            , arguments =
                                [ CodeGen.Expression.value "NotFound_"
                                ]
                            }
                        ]
                }
            , CodeGen.Declaration.function
                { name = "parser"
                , annotation = CodeGen.Annotation.type_ "Url.Parser.Parser (Route -> a) a"
                , arguments = []
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "Url.Parser.oneOf"
                        , arguments =
                            [ data.pages
                                |> List.map PageFile.toFilepath
                                |> List.map Filepath.toUrlParser
                                |> CodeGen.Expression.multilineList
                            ]
                        }
                }
            ]
        }


{-|

    module ElmLand.Layout exposing (Layout(..))

    type Layout
        = Default
        | Sidebar

-}
elmLandLayoutsElmModule : Data -> CodeGen.Module
elmLandLayoutsElmModule data =
    CodeGen.Module.new
        { name = [ "ElmLand", "Layout" ]
        , exposing_ = [ "Layout(..)" ]
        , imports = []
        , declarations =
            [ CodeGen.Declaration.customType
                { name = "Layout"
                , variants =
                    data.layouts
                        |> List.map Filepath.toRouteVariant
                }
            ]
        }


notFoundModule : CodeGen.Module
notFoundModule =
    CodeGen.Module.new
        { name = [ "Pages", "NotFound_" ]
        , exposing_ = [ "page" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "page"
                , arguments = []
                , annotation = CodeGen.Annotation.type_ "Html msg"
                , expression =
                    CodeGen.Expression.function
                        { name = "Html.text"
                        , arguments = [ CodeGen.Expression.string "Page not found..." ]
                        }
                }
            ]
        }


type alias Data =
    { pages : List PageFile
    , layouts : List Filepath
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "pages" (Json.Decode.list PageFile.decoder))
        (Json.Decode.field "layouts" (Json.Decode.list Filepath.decoder))
