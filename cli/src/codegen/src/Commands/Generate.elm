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
                  , CodeGen.Import.new [ "Effect" ]
                        |> CodeGen.Import.withExposing [ "Effect" ]
                  , CodeGen.Import.new [ "ElmLand", "Page" ]
                  , CodeGen.Import.new [ "ElmLand", "Request" ]
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
                  , CodeGen.Import.new [ "Shared" ]
                  , CodeGen.Import.new [ "Url" ]
                        |> CodeGen.Import.withExposing [ "Url" ]
                  , CodeGen.Import.new [ "View" ]
                        |> CodeGen.Import.withExposing [ "View" ]
                  ]
                ]
        , declarations =
            [ CodeGen.Declaration.typeAlias
                { name = "Flags"
                , annotation = CodeGen.Annotation.type_ "Shared.Flags"
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
                        , ( "shared", CodeGen.Annotation.type_ "Shared.Model" )
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
                            , { argument = CodeGen.Argument.new "( sharedModel, sharedCmd )"
                              , annotation = Nothing
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Shared.init"
                                        , arguments =
                                            [ CodeGen.Expression.value "flags"
                                            , CodeGen.Expression.parens [ CodeGen.Expression.value "ElmLand.Request.new () url" ]
                                            ]
                                        }
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.multilineTuple
                                [ CodeGen.Expression.multilineRecord
                                    [ ( "flags", CodeGen.Expression.value "flags" )
                                    , ( "url", CodeGen.Expression.value "url" )
                                    , ( "key", CodeGen.Expression.value "key" )
                                    , ( "page", CodeGen.Expression.value "pageModel" )
                                    , ( "shared", CodeGen.Expression.value "sharedModel" )
                                    ]
                                , CodeGen.Expression.multilineFunction
                                    { name = "Cmd.batch"
                                    , arguments =
                                        [ CodeGen.Expression.multilineList
                                            [ CodeGen.Expression.value "pageCmd"
                                            , CodeGen.Expression.function
                                                { name = "Cmd.map"
                                                , arguments =
                                                    [ CodeGen.Expression.value "SharedSentMsg"
                                                    , CodeGen.Expression.value "sharedCmd"
                                                    ]
                                                }
                                            ]
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
                    , ( "SharedSentMsg", [ CodeGen.Annotation.type_ "Shared.Msg" ] )
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
                                            [ { argument = CodeGen.Argument.new "sharedModel"
                                              , annotation = Just (CodeGen.Annotation.type_ "Shared.Model")
                                              , expression = CodeGen.Expression.value "model.shared"
                                              }
                                            , { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
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
                                                , CodeGen.Expression.value "pageCmd"
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
                                                            , CodeGen.Expression.value "model"
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
                                                , CodeGen.Expression.value "pageCmd"
                                                ]
                                        }
                              }
                            , { name = "SharedSentMsg"
                              , arguments = [ CodeGen.Argument.new "sharedMsg" ]
                              , expression =
                                    CodeGen.Expression.letIn
                                        { let_ =
                                            [ { argument = CodeGen.Argument.new "( sharedModel, sharedCmd )"
                                              , annotation = Nothing
                                              , expression =
                                                    CodeGen.Expression.function
                                                        { name = "Shared.update"
                                                        , arguments =
                                                            [ CodeGen.Expression.parens [ CodeGen.Expression.value "ElmLand.Request.new () model.url" ]
                                                            , CodeGen.Expression.value "sharedMsg"
                                                            , CodeGen.Expression.value "model.shared"
                                                            ]
                                                        }
                                              }
                                            ]
                                        , in_ =
                                            CodeGen.Expression.multilineTuple
                                                [ CodeGen.Expression.recordUpdate
                                                    { value = "model"
                                                    , fields =
                                                        [ ( "shared", CodeGen.Expression.value "sharedModel" )
                                                        ]
                                                    }
                                                , CodeGen.Expression.function
                                                    { name = "Cmd.map"
                                                    , arguments =
                                                        [ CodeGen.Expression.value "SharedSentMsg"
                                                        , CodeGen.Expression.value "sharedCmd"
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
                        , CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "( PageModel, Cmd Msg )"
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
                , expression = toViewCaseExpression data.pages
                }
            , CodeGen.Declaration.comment [ "INTERNALS" ]
            , CodeGen.Declaration.function
                { name = "fromEffect"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Effect PageMsg"
                        , CodeGen.Annotation.type_ "Cmd Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "effect" ]
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "Effect.toCmd"
                        , arguments =
                            [ CodeGen.Expression.multilineRecord
                                [ ( "fromPageMsg", CodeGen.Expression.value "PageSentMsg" )
                                , ( "fromSharedMsg", CodeGen.Expression.value "SharedSentMsg" )
                                ]
                            , CodeGen.Expression.value "effect"
                            ]
                        }
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
            , if PageFile.isSandboxOrElementElmLandPage page || PageFile.isAdvancedElmLandPage page then
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
                , if PageFile.isSandboxOrElementElmLandPage page || PageFile.isAdvancedElmLandPage page then
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


toViewCaseExpression : List PageFile -> CodeGen.Expression
toViewCaseExpression pages =
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
            if PageFile.isSandboxOrElementElmLandPage page then
                toBranchForElmLandPage False page filepath

            else if PageFile.isAdvancedElmLandPage page then
                toBranchForElmLandPage True page filepath

            else
                toBranchForStaticPage page filepath

        toBranchForElmLandPage : Bool -> PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForElmLandPage isAdvancedElmLandPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                conditionallyWrapInLayout page
                    (toPageModelMapper
                        { filepath = filepath
                        , isAdvancedElmLandPage = isAdvancedElmLandPage
                        , function = "view"
                        , mapper = "View.map"
                        }
                    )
            }

        toBranchForStaticPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForStaticPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                conditionallyWrapInLayout page
                    (callSandboxOrElementPageFunction filepath)
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
        , if PageFile.isSandboxOrElementElmLandPage page || PageFile.isAdvancedElmLandPage page then
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
                    [ CodeGen.Expression.value "model.page"
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
                    [ CodeGen.Expression.value "model.page"
                    , CodeGen.Expression.value "Cmd.none"
                    ]
            }

        toBranchForSandboxOrElementElmLandPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForSandboxOrElementElmLandPage page filepath =
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
                                { name = "Effect.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("PageMsg" ++ Filepath.toRouteVariantName filepath)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromEffect"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "ElmLand.Page.update"
                                , arguments =
                                    [ callSandboxOrElementPageFunction filepath
                                    , CodeGen.Expression.value "pageMsg"
                                    , CodeGen.Expression.value "pageModel"
                                    ]
                                }
                            ]
                        ]
                    }
            }

        toBranchForAdvancedElmLandPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForAdvancedElmLandPage page filepath =
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
                                { name = "Effect.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("PageMsg" ++ Filepath.toRouteVariantName filepath)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromEffect"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "ElmLand.Page.update"
                                , arguments =
                                    [ callAdvancedPageFunction "model.shared" "model.url" filepath
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
            if PageFile.isSandboxOrElementElmLandPage page then
                toBranchForSandboxOrElementElmLandPage page filepath

            else if PageFile.isAdvancedElmLandPage page then
                toBranchForAdvancedElmLandPage page filepath

            else
                toBranchForStaticPage page filepath
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "( msg, model.page )"
        , branches =
            List.concat
                [ List.map toBranch pages
                , [ { name = "( PageMsgNotFound_, PageModelNotFound_ )"
                    , arguments = []
                    , expression =
                        CodeGen.Expression.multilineTuple
                            [ CodeGen.Expression.value "model.page"
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

        toBranchForElmLandPage : Bool -> PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForElmLandPage isAdvancedElmLandPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                toPageModelMapper
                    { isAdvancedElmLandPage = isAdvancedElmLandPage
                    , filepath = filepath
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
            if PageFile.isSandboxOrElementElmLandPage page then
                toBranchForElmLandPage False page filepath

            else if PageFile.isAdvancedElmLandPage page then
                toBranchForElmLandPage True page filepath

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

        toBranchForSandboxOrElementElmLandPage : Filepath -> CodeGen.Expression
        toBranchForSandboxOrElementElmLandPage filepath =
            CodeGen.Expression.multilineFunction
                { name = "Tuple.mapBoth"
                , arguments =
                    [ pageModelConstructor filepath
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Effect.map"
                            , arguments =
                                [ CodeGen.Expression.value ("PageMsg" ++ Filepath.toRouteVariantName filepath)
                                ]
                            }
                        , CodeGen.Expression.operator ">>"
                        , CodeGen.Expression.value "fromEffect"
                        ]
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "ElmLand.Page.init"
                            , arguments =
                                [ callSandboxOrElementPageFunction filepath
                                , CodeGen.Expression.value "()"
                                ]
                            }
                        ]
                    ]
                }

        toBranchForAdvancedElmLandPage : Filepath -> CodeGen.Expression
        toBranchForAdvancedElmLandPage filepath =
            CodeGen.Expression.multilineFunction
                { name = "Tuple.mapBoth"
                , arguments =
                    [ pageModelConstructor filepath
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Effect.map"
                            , arguments =
                                [ CodeGen.Expression.value ("PageMsg" ++ Filepath.toRouteVariantName filepath)
                                ]
                            }
                        , CodeGen.Expression.operator ">>"
                        , CodeGen.Expression.value "fromEffect"
                        ]
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "ElmLand.Page.init"
                            , arguments =
                                [ callAdvancedPageFunction "sharedModel" "url" filepath
                                , CodeGen.Expression.value "()"
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
                    if PageFile.isSandboxOrElementElmLandPage page then
                        toBranchForSandboxOrElementElmLandPage filepath

                    else if PageFile.isAdvancedElmLandPage page then
                        toBranchForAdvancedElmLandPage filepath

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


callSandboxOrElementPageFunction : Filepath -> CodeGen.Expression
callSandboxOrElementPageFunction filepath =
    if Filepath.hasDynamicParameters filepath then
        CodeGen.Expression.parens
            [ CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")
            , CodeGen.Expression.value "params"
            ]

    else
        CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")


callAdvancedPageFunction : String -> String -> Filepath -> CodeGen.Expression
callAdvancedPageFunction sharedVarName urlVarName filepath =
    if Filepath.hasDynamicParameters filepath then
        CodeGen.Expression.parens
            [ CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")
            , CodeGen.Expression.value sharedVarName
            , CodeGen.Expression.value ("(ElmLand.Request.new params " ++ urlVarName ++ ")")
            ]

    else
        CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")


toPageModelMapper :
    { isAdvancedElmLandPage : Bool
    , filepath : Filepath
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
                [ if options.isAdvancedElmLandPage then
                    CodeGen.Expression.parens
                        [ CodeGen.Expression.value (pageModuleName ++ ".page")
                        , CodeGen.Expression.value "model.shared"
                        , CodeGen.Expression.value "(ElmLand.Request.new params model.url)"
                        ]

                  else if Filepath.hasDynamicParameters options.filepath then
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
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "page"
                , arguments = []
                , annotation = CodeGen.Annotation.type_ "View msg"
                , expression =
                    CodeGen.Expression.multilineRecord
                        [ ( "title", CodeGen.Expression.string "404" )
                        , ( "body"
                          , CodeGen.Expression.list
                                [ CodeGen.Expression.function
                                    { name = "Html.text"
                                    , arguments = [ CodeGen.Expression.string "Page not found..." ]
                                    }
                                ]
                          )
                        ]
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
