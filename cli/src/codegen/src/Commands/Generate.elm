module Commands.Generate exposing (run)

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
import PageFile exposing (PageFile)


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            List.concat
                [ [ mainElmModule data
                  , routePathElmModule data
                  ]
                , if List.isEmpty data.layouts then
                    []

                  else
                    [ layoutsElmModule data ]
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
                [ [ CodeGen.Import.new [ "Auth" ]
                  , CodeGen.Import.new [ "Auth", "Action" ]
                  , CodeGen.Import.new [ "Browser" ]
                  , CodeGen.Import.new [ "Browser", "Navigation" ]
                  , CodeGen.Import.new [ "Effect" ]
                        |> CodeGen.Import.withExposing [ "Effect" ]
                  , CodeGen.Import.new [ "Html" ]
                        |> CodeGen.Import.withExposing [ "Html" ]
                  , CodeGen.Import.new [ "Json", "Decode" ]
                  , CodeGen.Import.new [ "Page" ]
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
                  , CodeGen.Import.new [ "Route", "Path" ]
                  , CodeGen.Import.new [ "Shared" ]
                  , CodeGen.Import.new [ "Url" ]
                        |> CodeGen.Import.withExposing [ "Url" ]
                  , CodeGen.Import.new [ "View" ]
                        |> CodeGen.Import.withExposing [ "View" ]
                  ]
                ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "main"
                , annotation = CodeGen.Annotation.type_ "Program Json.Decode.Value Model Msg"
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
                        [ ( "key", CodeGen.Annotation.type_ "Browser.Navigation.Key" )
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
                        [ CodeGen.Annotation.type_ "Json.Decode.Value"
                        , CodeGen.Annotation.type_ "Url"
                        , CodeGen.Annotation.type_ "Browser.Navigation.Key"
                        , CodeGen.Annotation.type_ "( Model, Cmd Msg )"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "json"
                    , CodeGen.Argument.new "url"
                    , CodeGen.Argument.new "key"
                    ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "flagsResult"
                              , annotation = Just (CodeGen.Annotation.type_ "Result Json.Decode.Error Shared.Flags")
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Json.Decode.decodeValue"
                                        , arguments =
                                            [ CodeGen.Expression.value "Shared.decoder"
                                            , CodeGen.Expression.value "json"
                                            ]
                                        }
                              }
                            , { argument = CodeGen.Argument.new "( sharedModel, sharedEffect )"
                              , annotation = Nothing
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Shared.init"
                                        , arguments =
                                            [ CodeGen.Expression.value "flagsResult"
                                            , CodeGen.Expression.parens [ CodeGen.Expression.value "Route.fromUrl () url" ]
                                            ]
                                        }
                              }
                            , { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                              , annotation = Nothing
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "initPage"
                                        , arguments =
                                            [ CodeGen.Expression.record
                                                [ ( "key", CodeGen.Expression.value "key" )
                                                , ( "url", CodeGen.Expression.value "url" )
                                                , ( "shared", CodeGen.Expression.value "sharedModel" )
                                                ]
                                            ]
                                        }
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.multilineTuple
                                [ CodeGen.Expression.multilineRecord
                                    [ ( "url", CodeGen.Expression.value "url" )
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
                                                { name = "fromSharedEffect"
                                                , arguments =
                                                    [ CodeGen.Expression.value "key"
                                                    , CodeGen.Expression.value "sharedEffect"
                                                    ]
                                                }
                                            ]
                                        ]
                                    }
                                ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "initPage"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.record
                            [ ( "key", CodeGen.Annotation.type_ "Browser.Navigation.Key" )
                            , ( "url", CodeGen.Annotation.type_ "Url" )
                            , ( "shared", CodeGen.Annotation.type_ "Shared.Model" )
                            ]
                        , CodeGen.Annotation.type_ "( PageModel, Cmd Msg )"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = toInitPageCaseExpression data.pages
                }
            , runWhenAuthenticatedDeclaration
            , CodeGen.Declaration.comment [ "UPDATE" ]
            , CodeGen.Declaration.customType
                { name = "Msg"
                , variants =
                    [ ( "UrlRequested", [ CodeGen.Annotation.type_ "Browser.UrlRequest" ] )
                    , ( "UrlChanged", [ CodeGen.Annotation.type_ "Url" ] )
                    , ( "PageSent", [ CodeGen.Annotation.type_ "PageMsg" ] )
                    , ( "SharedSent", [ CodeGen.Annotation.type_ "Shared.Msg" ] )
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
                                              , expression =
                                                    CodeGen.Expression.function
                                                        { name = "initPage"
                                                        , arguments =
                                                            [ CodeGen.Expression.record
                                                                [ ( "key", CodeGen.Expression.value "model.key" )
                                                                , ( "shared", CodeGen.Expression.value "model.shared" )
                                                                , ( "url", CodeGen.Expression.value "url" )
                                                                ]
                                                            ]
                                                        }
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
                            , { name = "PageSent"
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
                            , { name = "SharedSent"
                              , arguments = [ CodeGen.Argument.new "sharedMsg" ]
                              , expression =
                                    CodeGen.Expression.letIn
                                        { let_ =
                                            [ { argument = CodeGen.Argument.new "( sharedModel, sharedEffect )"
                                              , annotation = Nothing
                                              , expression =
                                                    CodeGen.Expression.function
                                                        { name = "Shared.update"
                                                        , arguments =
                                                            [ CodeGen.Expression.parens [ CodeGen.Expression.value "Route.fromUrl () model.url" ]
                                                            , CodeGen.Expression.value "sharedMsg"
                                                            , CodeGen.Expression.value "model.shared"
                                                            ]
                                                        }
                                              }
                                            , { argument = CodeGen.Argument.new "( oldAction, newAction )"
                                              , annotation = Nothing
                                              , expression =
                                                    CodeGen.Expression.multilineTuple
                                                        [ CodeGen.Expression.value "Auth.onPageLoad model.shared (Route.fromUrl () model.url)"
                                                        , CodeGen.Expression.value "Auth.onPageLoad sharedModel (Route.fromUrl () model.url)"
                                                        ]
                                              }
                                            ]
                                        , in_ =
                                            CodeGen.Expression.caseExpression
                                                { value = CodeGen.Argument.new "oldAction /= newAction"
                                                , branches =
                                                    [ { name = "True"
                                                      , arguments = []
                                                      , expression =
                                                            CodeGen.Expression.letIn
                                                                { let_ =
                                                                    [ { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                                                                      , annotation = Nothing
                                                                      , expression =
                                                                            CodeGen.Expression.value "initPage { key = model.key, shared = sharedModel, url = model.url }"
                                                                      }
                                                                    ]
                                                                , in_ =
                                                                    CodeGen.Expression.multilineTuple
                                                                        [ CodeGen.Expression.value "{ model | shared = sharedModel, page = pageModel }"
                                                                        , CodeGen.Expression.multilineFunction
                                                                            { name = "Cmd.batch"
                                                                            , arguments =
                                                                                [ CodeGen.Expression.multilineList
                                                                                    [ CodeGen.Expression.value "pageCmd"
                                                                                    , CodeGen.Expression.value "fromSharedEffect model.key sharedEffect"
                                                                                    ]
                                                                                ]
                                                                            }
                                                                        ]
                                                                }
                                                      }
                                                    , { name = "False"
                                                      , arguments = []
                                                      , expression =
                                                            CodeGen.Expression.multilineTuple
                                                                [ CodeGen.Expression.recordUpdate
                                                                    { value = "model"
                                                                    , fields =
                                                                        [ ( "shared", CodeGen.Expression.value "sharedModel" )
                                                                        ]
                                                                    }
                                                                , CodeGen.Expression.function
                                                                    { name = "fromSharedEffect"
                                                                    , arguments =
                                                                        [ CodeGen.Expression.value "model.key"
                                                                        , CodeGen.Expression.value "sharedEffect"
                                                                        ]
                                                                    }
                                                                ]
                                                      }
                                                    ]
                                                }
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
            , fromEffectDeclaration
                { name = "fromPageEffect"
                , msgType = "PageMsg"
                , fromPageMsg = "PageSent"
                }
            , fromEffectDeclaration
                { name = "fromSharedEffect"
                , msgType = "Shared.Msg"
                , fromPageMsg = "SharedSent"
                }
            ]
        }


fromEffectDeclaration :
    { name : String
    , msgType : String
    , fromPageMsg : String
    }
    -> CodeGen.Declaration
fromEffectDeclaration options =
    CodeGen.Declaration.function
        { name = options.name
        , annotation =
            CodeGen.Annotation.function
                [ CodeGen.Annotation.type_ "Browser.Navigation.Key"
                , CodeGen.Annotation.type_ ("Effect " ++ options.msgType)
                , CodeGen.Annotation.type_ "Cmd Msg"
                ]
        , arguments =
            [ CodeGen.Argument.new "key"
            , CodeGen.Argument.new "effect"
            ]
        , expression =
            CodeGen.Expression.multilineFunction
                { name = "Effect.toCmd"
                , arguments =
                    [ CodeGen.Expression.multilineRecord
                        [ ( "key", CodeGen.Expression.value "key" )
                        , ( "fromPageMsg", CodeGen.Expression.value options.fromPageMsg )
                        , ( "fromSharedMsg", CodeGen.Expression.value "SharedSent" )
                        ]
                    , CodeGen.Expression.value "effect"
                    ]
                }
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
            ( "Msg_" ++ Filepath.toRouteVariantName filepath
            , if PageFile.isSandboxOrElementElmLandPage page || PageFile.isAdvancedElmLandPage page then
                [ CodeGen.Annotation.type_ (Filepath.toPageModuleName filepath ++ ".Msg")
                ]

              else
                []
            )
    in
    List.concat
        [ List.map toCustomType pages
        , [ ( "Msg_NotFound_", [] ) ]
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
        , [ ( "PageModelNotFound_", [] )
          , ( "Redirecting", [] )
          , ( "Loading", [ CodeGen.Annotation.type_ "(View Never)" ] )
          ]
        ]


runWhenAuthenticatedDeclaration : CodeGen.Declaration
runWhenAuthenticatedDeclaration =
    CodeGen.Declaration.function
        { name = "runWhenAuthenticated"
        , annotation =
            CodeGen.Annotation.function
                [ CodeGen.Annotation.type_ "{ model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key }"
                , CodeGen.Annotation.type_ "(Auth.User -> ( PageModel, Cmd Msg ))"
                , CodeGen.Annotation.type_ "( PageModel, Cmd Msg )"
                ]
        , arguments = [ CodeGen.Argument.new "model", CodeGen.Argument.new "toTuple" ]
        , expression =
            CodeGen.Expression.letIn
                { let_ =
                    [ { argument = CodeGen.Argument.new "authAction"
                      , annotation = Just (CodeGen.Annotation.type_ "Auth.Action.Action Auth.User")
                      , expression = CodeGen.Expression.value "Auth.onPageLoad model.shared (Route.fromUrl () model.url)"
                      }
                    , { argument = CodeGen.Argument.new "toCmd"
                      , annotation = Just (CodeGen.Annotation.type_ "Effect Msg -> Cmd Msg")
                      , expression =
                            CodeGen.Expression.multilineFunction
                                { name = "Effect.toCmd"
                                , arguments =
                                    [ CodeGen.Expression.multilineRecord
                                        [ ( "key", CodeGen.Expression.value "model.key" )
                                        , ( "fromSharedMsg", CodeGen.Expression.value "SharedSent" )
                                        , ( "fromPageMsg", CodeGen.Expression.value "identity" )
                                        ]
                                    ]
                                }
                      }
                    ]
                , in_ =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "authAction"
                        , branches =
                            [ { name = "Auth.Action.LoadPageWithUser"
                              , arguments = [ CodeGen.Argument.new "user" ]
                              , expression = CodeGen.Expression.value "toTuple user"
                              }
                            , { name = "Auth.Action.ReplaceRoute"
                              , arguments = [ CodeGen.Argument.new "options" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "Redirecting"
                                        , CodeGen.Expression.value "toCmd (Effect.replaceRoute options)"
                                        ]
                              }
                            , { name = "Auth.Action.PushRoute"
                              , arguments = [ CodeGen.Argument.new "options" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "Redirecting"
                                        , CodeGen.Expression.value "toCmd (Effect.pushRoute options)"
                                        ]
                              }
                            , { name = "Auth.Action.ShowLoadingPage"
                              , arguments = [ CodeGen.Argument.new "loadingView" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "Loading loadingView"
                                        , CodeGen.Expression.value "Cmd.none"
                                        ]
                              }
                            ]
                        }
                }
        }


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
                toPageModelMapper
                    { filepath = filepath
                    , isAdvancedElmLandPage = isAdvancedElmLandPage
                    , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                    , function = "view"
                    , mapper = "View.map"
                    }
                    |> conditionallyWrapInAuthView page
                    |> conditionallyWrapInLayout page
            }

        conditionallyWrapInAuthView : PageFile -> CodeGen.Expression -> CodeGen.Expression
        conditionallyWrapInAuthView page expression =
            if PageFile.isAuthProtectedPage page then
                CodeGen.Expression.multilineFunction
                    { name = "Auth.Action.view"
                    , arguments =
                        [ CodeGen.Expression.parens
                            [ CodeGen.Expression.lambda
                                { arguments = [ CodeGen.Argument.new "user" ]
                                , expression = expression
                                }
                            ]
                        , CodeGen.Expression.value "(Auth.onPageLoad model.shared (Route.fromUrl () model.url))"
                        ]
                    }

            else
                expression

        toBranchForStaticPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForStaticPage page filepath =
            { name = "PageModel" ++ Filepath.toRouteVariantName filepath
            , arguments = toPageModelArgs page filepath
            , expression =
                callSandboxOrElementPageFunction page filepath
                    |> conditionallyWrapInAuthView page
                    |> conditionallyWrapInLayout page
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
                  , { name = "Redirecting"
                    , arguments = []
                    , expression = CodeGen.Expression.value "View.none"
                    }
                  , { name = "Loading loadingView"
                    , arguments = []
                    , expression = CodeGen.Expression.value "View.map never loadingView"
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
                "( Msg_{{name}}, PageModel{{name}}{{args}} )"
                    |> String.replace "{{name}}" (Filepath.toRouteVariantName filepath)
                    |> String.replace "{{args}}"
                        (case toPageModelArgs page filepath of
                            [] ->
                                ""

                            args ->
                                args
                                    |> List.map CodeGen.Argument.toString
                                    |> String.join " "
                                    |> String.append " "
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
                "( Msg_{{name}} pageMsg, PageModel{{name}} {{args}} )"
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
                                    [ CodeGen.Expression.value ("Msg_" ++ Filepath.toRouteVariantName filepath)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromPageEffect model.key"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Page.update"
                                , arguments =
                                    [ callSandboxOrElementPageFunction page filepath
                                    , CodeGen.Expression.value "pageMsg"
                                    , CodeGen.Expression.value "pageModel"
                                    ]
                                }
                            ]
                        ]
                    }
                    |> conditionallyWrapInRunWhenAuthenticated page
            }

        toBranchForAdvancedElmLandPage : PageFile -> Filepath -> CodeGen.Expression.Branch
        toBranchForAdvancedElmLandPage page filepath =
            { name =
                "( Msg_{{name}} pageMsg, PageModel{{name}} {{args}} )"
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
                                    [ CodeGen.Expression.value ("Msg_" ++ Filepath.toRouteVariantName filepath)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromPageEffect model.key"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Page.update"
                                , arguments =
                                    [ callAdvancedPageFunction page "model.url" filepath
                                    , CodeGen.Expression.value "pageMsg"
                                    , CodeGen.Expression.value "pageModel"
                                    ]
                                }
                            ]
                        ]
                    }
                    |> conditionallyWrapInRunWhenAuthenticated page
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
                , [ { name = "( Msg_NotFound_, PageModelNotFound_ )"
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
                    , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                    , filepath = filepath
                    , function = "subscriptions"
                    , mapper = "Sub.map"
                    }
                    |> conditionallyWrapInAuthSubscriptions page
            }

        conditionallyWrapInAuthSubscriptions : PageFile -> CodeGen.Expression -> CodeGen.Expression
        conditionallyWrapInAuthSubscriptions page expression =
            if PageFile.isAuthProtectedPage page then
                CodeGen.Expression.multilineFunction
                    { name = "Auth.Action.subscriptions"
                    , arguments =
                        [ CodeGen.Expression.parens
                            [ CodeGen.Expression.lambda
                                { arguments = [ CodeGen.Argument.new "user" ]
                                , expression = expression
                                }
                            ]
                        , CodeGen.Expression.value "(Auth.onPageLoad model.shared (Route.fromUrl () model.url))"
                        ]
                    }

            else
                expression

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
                  , { name = "Redirecting"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  , { name = "Loading _"
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
            CodeGen.Expression.tuple
                [ pageModelConstructor filepath
                , CodeGen.Expression.value "Cmd.none"
                ]

        toBranchForSandboxOrElementElmLandPage : PageFile -> Filepath -> CodeGen.Expression
        toBranchForSandboxOrElementElmLandPage pageFile filepath =
            CodeGen.Expression.multilineFunction
                { name = "Tuple.mapBoth"
                , arguments =
                    [ pageModelConstructor filepath
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Effect.map"
                            , arguments =
                                [ CodeGen.Expression.value ("Msg_" ++ Filepath.toRouteVariantName filepath)
                                ]
                            }
                        , CodeGen.Expression.operator ">>"
                        , CodeGen.Expression.value "fromPageEffect model.key"
                        ]
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Page.init"
                            , arguments =
                                [ callSandboxOrElementPageFunction pageFile filepath
                                , CodeGen.Expression.value "()"
                                ]
                            }
                        ]
                    ]
                }

        toBranchForAdvancedElmLandPage : PageFile -> Filepath -> CodeGen.Expression
        toBranchForAdvancedElmLandPage page filepath =
            CodeGen.Expression.multilineFunction
                { name = "Tuple.mapBoth"
                , arguments =
                    [ pageModelConstructor filepath
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Effect.map"
                            , arguments =
                                [ CodeGen.Expression.value ("Msg_" ++ Filepath.toRouteVariantName filepath)
                                ]
                            }
                        , CodeGen.Expression.operator ">>"
                        , CodeGen.Expression.value "fromPageEffect model.key"
                        ]
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Page.init"
                            , arguments =
                                [ callAdvancedPageFunction page "model.url" filepath
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

                branchExpression : CodeGen.Expression
                branchExpression =
                    conditionallyWrapInRunWhenAuthenticated page
                        (if PageFile.isSandboxOrElementElmLandPage page then
                            toBranchForSandboxOrElementElmLandPage page filepath

                         else if PageFile.isAdvancedElmLandPage page then
                            toBranchForAdvancedElmLandPage page filepath

                         else
                            toBranchExpressionForStaticPage filepath
                        )
            in
            if Filepath.hasDynamicParameters filepath then
                { name = "Route.Path." ++ Filepath.toRouteVariantName filepath
                , arguments = [ CodeGen.Argument.new "params" ]
                , expression = branchExpression
                }

            else
                { name = "Route.Path." ++ Filepath.toRouteVariantName filepath
                , arguments = []
                , expression = branchExpression
                }
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "Route.Path.fromUrl model.url"
        , branches =
            List.concat
                [ List.map toBranch pages
                , [ { name = "Route.Path.NotFound_"
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


conditionallyWrapInRunWhenAuthenticated : PageFile -> CodeGen.Expression -> CodeGen.Expression
conditionallyWrapInRunWhenAuthenticated page expression =
    if PageFile.isAuthProtectedPage page then
        CodeGen.Expression.multilineFunction
            { name = "runWhenAuthenticated"
            , arguments =
                [ CodeGen.Expression.value "model"
                , CodeGen.Expression.lambda
                    { arguments = [ CodeGen.Argument.new "user" ]
                    , expression = expression
                    }
                ]
            }

    else
        expression


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


callSandboxOrElementPageFunction : PageFile -> Filepath -> CodeGen.Expression
callSandboxOrElementPageFunction pageFile filepath =
    let
        arguments : List CodeGen.Expression
        arguments =
            List.concat
                [ if PageFile.isAuthProtectedPage pageFile then
                    [ CodeGen.Expression.value "user" ]

                  else
                    []
                , if Filepath.hasDynamicParameters filepath then
                    [ CodeGen.Expression.value "params" ]

                  else
                    []
                ]
    in
    CodeGen.Expression.parens
        [ CodeGen.Expression.function
            { name = Filepath.toPageModuleName filepath ++ ".page"
            , arguments = arguments
            }
        ]


callAdvancedPageFunction : PageFile -> String -> Filepath -> CodeGen.Expression
callAdvancedPageFunction page urlVarName filepath =
    CodeGen.Expression.parens
        [ CodeGen.Expression.value (Filepath.toPageModuleName filepath ++ ".page")
        , if PageFile.isAuthProtectedPage page then
            CodeGen.Expression.value "user model.shared"

          else
            CodeGen.Expression.value "model.shared"
        , if Filepath.hasDynamicParameters filepath then
            CodeGen.Expression.value ("(Route.fromUrl params " ++ urlVarName ++ ")")

          else
            CodeGen.Expression.value ("(Route.fromUrl () " ++ urlVarName ++ ")")
        ]


toPageModelMapper :
    { isAdvancedElmLandPage : Bool
    , isAuthProtectedPage : Bool
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
            { name = "Page." ++ options.function
            , arguments =
                [ if options.isAdvancedElmLandPage then
                    CodeGen.Expression.parens
                        [ CodeGen.Expression.value (pageModuleName ++ ".page")
                        , if options.isAuthProtectedPage then
                            CodeGen.Expression.value "user model.shared"

                          else
                            CodeGen.Expression.value "model.shared"
                        , if Filepath.hasDynamicParameters options.filepath then
                            CodeGen.Expression.value "(Route.fromUrl params model.url)"

                          else
                            CodeGen.Expression.value "(Route.fromUrl () model.url)"
                        ]

                  else if Filepath.hasDynamicParameters options.filepath then
                    CodeGen.Expression.parens
                        [ CodeGen.Expression.value (pageModuleName ++ ".page")
                        , if options.isAuthProtectedPage then
                            CodeGen.Expression.value "user params"

                          else
                            CodeGen.Expression.value "params"
                        ]

                  else if options.isAuthProtectedPage then
                    CodeGen.Expression.parens
                        [ CodeGen.Expression.value (pageModuleName ++ ".page user")
                        ]

                  else
                    CodeGen.Expression.value (pageModuleName ++ ".page")
                , CodeGen.Expression.value "pageModel"
                ]
            }
        , CodeGen.Expression.function
            { name = options.mapper
            , arguments = [ CodeGen.Expression.value ("Msg_" ++ routeVariantName) ]
            }
        , CodeGen.Expression.function
            { name = options.mapper
            , arguments = [ CodeGen.Expression.value "PageSent" ]
            }
        ]


routePathElmModule : Data -> CodeGen.Module
routePathElmModule data =
    CodeGen.Module.new
        { name = [ "Route", "Path" ]
        , exposing_ = [ "Path(..)", "fromUrl", "toString", "href" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
            , CodeGen.Import.new [ "Html.Attributes" ]
            , CodeGen.Import.new [ "Url" ]
                |> CodeGen.Import.withExposing [ "Url" ]
            , CodeGen.Import.new [ "Url.Parser" ]
                |> CodeGen.Import.withExposing [ "(</>)" ]
            ]
        , declarations =
            [ CodeGen.Declaration.customType
                { name = "Path"
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
                        , CodeGen.Annotation.type_ "Path"
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
                { name = "href"
                , annotation = CodeGen.Annotation.function [ CodeGen.Annotation.type_ "Path", CodeGen.Annotation.type_ "Html.Attribute msg" ]
                , arguments = [ CodeGen.Argument.new "path" ]
                , expression = CodeGen.Expression.value "Html.Attributes.href (toString path)"
                }
            , CodeGen.Declaration.function
                { name = "toString"
                , annotation = CodeGen.Annotation.function [ CodeGen.Annotation.type_ "Path", CodeGen.Annotation.type_ "String" ]
                , arguments = [ CodeGen.Argument.new "path" ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "pieces"
                              , annotation = Nothing
                              , expression =
                                    CodeGen.Expression.caseExpression
                                        { value = CodeGen.Argument.new "path"
                                        , branches = toRoutePathToStringBranches data.pages
                                        }
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.pipeline
                                [ CodeGen.Expression.value "pieces"
                                , CodeGen.Expression.function
                                    { name = "String.join"
                                    , arguments = [ CodeGen.Expression.string "/" ]
                                    }
                                , CodeGen.Expression.function
                                    { name = "String.append"
                                    , arguments = [ CodeGen.Expression.string "/" ]
                                    }
                                ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "parser"
                , annotation = CodeGen.Annotation.type_ "Url.Parser.Parser (Path -> a) a"
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


toRoutePathToStringBranches : List PageFile -> List CodeGen.Expression.Branch
toRoutePathToStringBranches files =
    List.map toRoutePathToStringBranch files
        ++ [ { name = "NotFound_"
             , arguments = []
             , expression = CodeGen.Expression.list [ CodeGen.Expression.string "404" ]
             }
           ]


toRoutePathToStringBranch : PageFile -> CodeGen.Expression.Branch
toRoutePathToStringBranch file =
    let
        filepath : Filepath
        filepath =
            PageFile.toFilepath file
    in
    { name = Filepath.toRouteVariantName filepath
    , arguments =
        if Filepath.hasDynamicParameters filepath then
            [ CodeGen.Argument.new "params" ]

        else
            []
    , expression =
        if Filepath.toRouteVariantName filepath == "Home_" then
            CodeGen.Expression.list []

        else
            CodeGen.Expression.list
                (Filepath.toList filepath
                    |> List.map
                        (\piece ->
                            if String.endsWith "_" piece then
                                CodeGen.Expression.value
                                    ("params."
                                        ++ (piece |> String.dropRight 1 |> Extras.String.fromPascalCaseToCamelCase)
                                    )

                            else
                                CodeGen.Expression.string (Extras.String.fromPascalCaseToKebabCase piece)
                        )
                )
    }


{-|

    module Layout exposing (Layout(..))

    type Layout
        = Default
        | Sidebar

-}
layoutsElmModule : Data -> CodeGen.Module
layoutsElmModule data =
    CodeGen.Module.new
        { name = [ "Layout" ]
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


type alias Data =
    { pages : List PageFile
    , layouts : List Filepath
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "pages"
            (Json.Decode.list PageFile.decoder
                |> Json.Decode.map ignoreNotFoundPage
            )
        )
        (Json.Decode.field "layouts" (Json.Decode.list Filepath.decoder))


ignoreNotFoundPage : List PageFile -> List PageFile
ignoreNotFoundPage pageFiles =
    pageFiles
        |> List.filter (PageFile.isNotFoundPage >> not)
