module Commands.Generate exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Extras.String
import Json.Decode
import LayoutFile exposing (LayoutFile)
import PageFile exposing (PageFile)


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            [ mainElmModule data
            , routePathElmModule data
            , layoutsElmModule data
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
                  ]
                , if List.isEmpty data.layouts then
                    []

                  else
                    [ CodeGen.Import.new [ "Layout" ]
                    , CodeGen.Import.new [ "Layouts" ]
                    ]
                , data.layouts
                    |> List.map LayoutFile.toList
                    |> List.map (\pieces -> "Layouts" :: pieces)
                    |> List.map CodeGen.Import.new
                , [ CodeGen.Import.new [ "Page" ]
                  ]
                , data.pages
                    |> List.map PageFile.toList
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
                                , ( "view", CodeGen.Expression.value "View.toBrowserDocument << view" )
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
                        , ( "layout", CodeGen.Annotation.type_ "Maybe LayoutModel" )
                        , ( "shared", CodeGen.Annotation.type_ "Shared.Model" )
                        ]
                }
            , PageFile.toPageModelTypeDeclaration data.pages
            , LayoutFile.toLayoutsModelTypeDeclaration data.layouts
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
                            , { argument = CodeGen.Argument.new "{ page, layout }"
                              , annotation = Nothing
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "initPageAndLayout"
                                        , arguments =
                                            [ CodeGen.Expression.record
                                                [ ( "key", CodeGen.Expression.value "key" )
                                                , ( "url", CodeGen.Expression.value "url" )
                                                , ( "shared", CodeGen.Expression.value "sharedModel" )
                                                , ( "layout", CodeGen.Expression.value "Nothing" )
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
                                    , ( "page", CodeGen.Expression.value "Tuple.first page" )
                                    , ( "layout", CodeGen.Expression.value "layout |> Maybe.map Tuple.first" )
                                    , ( "shared", CodeGen.Expression.value "sharedModel" )
                                    ]
                                , CodeGen.Expression.multilineFunction
                                    { name = "Cmd.batch"
                                    , arguments =
                                        [ CodeGen.Expression.multilineList
                                            [ CodeGen.Expression.value "Tuple.second page"
                                            , CodeGen.Expression.value "layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none"
                                            , CodeGen.Expression.function
                                                { name = "fromSharedEffect"
                                                , arguments =
                                                    [ CodeGen.Expression.value "{ key = key, url = url, shared = sharedModel }"
                                                    , CodeGen.Expression.value "sharedEffect"
                                                    ]
                                                }
                                            ]
                                        ]
                                    }
                                ]
                        }
                }
            , if List.isEmpty data.layouts then
                CodeGen.Declaration.none

              else
                CodeGen.Declaration.function
                    { name = "initLayout"
                    , annotation =
                        CodeGen.Annotation.function
                            [ CodeGen.Annotation.record
                                [ ( "key", CodeGen.Annotation.type_ "Browser.Navigation.Key" )
                                , ( "url", CodeGen.Annotation.type_ "Url" )
                                , ( "shared", CodeGen.Annotation.type_ "Shared.Model" )
                                , ( "layout", CodeGen.Annotation.type_ "Maybe LayoutModel" )
                                ]
                            , CodeGen.Annotation.type_ "Layouts.Layout"
                            , CodeGen.Annotation.type_ "( LayoutModel, Cmd Msg )"
                            ]
                    , arguments = [ CodeGen.Argument.new "model", CodeGen.Argument.new "layout" ]
                    , expression = toInitLayoutCaseExpression data.layouts
                    }
            , CodeGen.Declaration.function
                { name = "initPageAndLayout"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.record
                            [ ( "key", CodeGen.Annotation.type_ "Browser.Navigation.Key" )
                            , ( "url", CodeGen.Annotation.type_ "Url" )
                            , ( "shared", CodeGen.Annotation.type_ "Shared.Model" )
                            , ( "layout", CodeGen.Annotation.type_ "Maybe LayoutModel" )
                            ]
                        , CodeGen.Annotation.type_ "{ page : ( PageModel, Cmd Msg ), layout : Maybe ( LayoutModel, Cmd Msg ) }"
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
                    , ( "LayoutSent", [ CodeGen.Annotation.type_ "LayoutMsg" ] )
                    , ( "SharedSent", [ CodeGen.Annotation.type_ "Shared.Msg" ] )
                    ]
                }
            , CodeGen.Declaration.customType
                { name = "PageMsg"
                , variants = toPageMsgCustomType data.pages
                }
            , LayoutFile.toLayoutsMsgTypeDeclaration data.layouts
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
                                    CodeGen.Expression.ifElse
                                        { condition = CodeGen.Expression.value "url.path == model.url.path"
                                        , ifBranch =
                                            CodeGen.Expression.multilineTuple
                                                [ CodeGen.Expression.value "{ model | url = url }"
                                                , CodeGen.Expression.value "Cmd.none"
                                                ]
                                        , elseBranch =
                                            CodeGen.Expression.letIn
                                                { let_ =
                                                    [ { argument = CodeGen.Argument.new "{ page, layout }"
                                                      , annotation = Nothing
                                                      , expression =
                                                            CodeGen.Expression.function
                                                                { name = "initPageAndLayout"
                                                                , arguments =
                                                                    [ CodeGen.Expression.record
                                                                        [ ( "key", CodeGen.Expression.value "model.key" )
                                                                        , ( "shared", CodeGen.Expression.value "model.shared" )
                                                                        , ( "layout", CodeGen.Expression.value "model.layout" )
                                                                        , ( "url", CodeGen.Expression.value "url" )
                                                                        ]
                                                                    ]
                                                                }
                                                      }
                                                    , { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                                                      , annotation = Nothing
                                                      , expression = CodeGen.Expression.value "page"
                                                      }
                                                    , { argument = CodeGen.Argument.new "( layoutModel, layoutCmd )"
                                                      , annotation = Nothing
                                                      , expression =
                                                            CodeGen.Expression.caseExpression
                                                                { value = CodeGen.Argument.new "layout"
                                                                , branches =
                                                                    [ { name = "Just"
                                                                      , arguments = [ CodeGen.Argument.new "( layoutModel_, layoutCmd_ )" ]
                                                                      , expression = CodeGen.Expression.value "( Just layoutModel_, layoutCmd_ )"
                                                                      }
                                                                    , { name = "Nothing"
                                                                      , arguments = []
                                                                      , expression = CodeGen.Expression.value "( Nothing, Cmd.none )"
                                                                      }
                                                                    ]
                                                                }
                                                      }
                                                    ]
                                                , in_ =
                                                    CodeGen.Expression.multilineTuple
                                                        [ CodeGen.Expression.value "{ model | url = url, page = pageModel, layout = layoutModel }"
                                                        , CodeGen.Expression.value "Cmd.batch [ pageCmd, layoutCmd ]"
                                                        ]
                                                }
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
                            , { name = "LayoutSent"
                              , arguments = [ CodeGen.Argument.new "layoutMsg" ]
                              , expression =
                                    CodeGen.Expression.letIn
                                        { let_ =
                                            [ { argument = CodeGen.Argument.new "( layoutModel, layoutCmd )"
                                              , annotation = Nothing
                                              , expression =
                                                    CodeGen.Expression.function
                                                        { name = "updateFromLayout"
                                                        , arguments =
                                                            [ CodeGen.Expression.value "layoutMsg"
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
                                                        [ ( "layout", CodeGen.Expression.value "layoutModel" )
                                                        ]
                                                    }
                                                , CodeGen.Expression.value "layoutCmd"
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
                                                                    [ { argument = CodeGen.Argument.new "{ page }"
                                                                      , annotation = Nothing
                                                                      , expression =
                                                                            CodeGen.Expression.value "initPageAndLayout { key = model.key, shared = sharedModel, url = model.url, layout = model.layout }"
                                                                      }
                                                                    , { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                                                                      , annotation = Nothing
                                                                      , expression = CodeGen.Expression.value "page"
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
                                                                                    , CodeGen.Expression.value "fromSharedEffect { model | shared = sharedModel } sharedEffect"
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
                                                                , CodeGen.Expression.value "fromSharedEffect { model | shared = sharedModel } sharedEffect"
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
                { name = "updateFromLayout"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "LayoutMsg"
                        , CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "( Maybe LayoutModel, Cmd Msg )"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "msg"
                    , CodeGen.Argument.new "model"
                    ]
                , expression = toUpdateLayoutCaseExpression data.layouts
                }
            , CodeGen.Declaration.function
                { name = "subscriptions"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "Sub Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "subscriptionsFromPage"
                              , annotation = Just (CodeGen.Annotation.type_ "Sub Msg")
                              , expression = toSubscriptionPageCaseExpression data.pages
                              }
                            , { argument = CodeGen.Argument.new "subscriptionsFromLayout"
                              , annotation = Just (CodeGen.Annotation.type_ "Sub Msg")
                              , expression = toSubscriptionLayoutCaseExpression data.layouts
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.multilineFunction
                                { name = "Sub.batch"
                                , arguments =
                                    [ CodeGen.Expression.multilineList
                                        [ CodeGen.Expression.pipeline
                                            [ CodeGen.Expression.function
                                                { name = "Shared.subscriptions"
                                                , arguments =
                                                    [ CodeGen.Expression.parens [ CodeGen.Expression.value "Route.fromUrl () model.url" ]
                                                    , CodeGen.Expression.value "model.shared"
                                                    ]
                                                }
                                            , CodeGen.Expression.value "Sub.map SharedSent"
                                            ]
                                        , CodeGen.Expression.value "subscriptionsFromPage"
                                        , CodeGen.Expression.value "subscriptionsFromLayout"
                                        ]
                                    ]
                                }
                        }
                }
            , CodeGen.Declaration.comment [ "VIEW" ]
            , CodeGen.Declaration.function
                { name = "view"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "View Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = toViewCaseExpression data.layouts
                }
            , CodeGen.Declaration.function
                { name = "viewPage"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "View Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = toViewPageCaseExpression data.pages
                }
            , CodeGen.Declaration.comment [ "INTERNALS" ]
            , fromEffectDeclaration
                { name = "fromPageEffect"
                , msgType = "PageMsg"
                , toMainMsg = "PageSent"
                }
            , fromEffectDeclaration
                { name = "fromLayoutEffect"
                , msgType = "LayoutMsg"
                , toMainMsg = "LayoutSent"
                }
            , fromEffectDeclaration
                { name = "fromSharedEffect"
                , msgType = "Shared.Msg"
                , toMainMsg = "SharedSent"
                }
            ]
        }


fromEffectDeclaration :
    { name : String
    , msgType : String
    , toMainMsg : String
    }
    -> CodeGen.Declaration
fromEffectDeclaration options =
    CodeGen.Declaration.function
        { name = options.name
        , annotation =
            CodeGen.Annotation.function
                [ CodeGen.Annotation.type_ "{ model | key : Browser.Navigation.Key, url : Url, shared : Shared.Model }"
                , CodeGen.Annotation.type_ ("Effect " ++ options.msgType)
                , CodeGen.Annotation.type_ "Cmd Msg"
                ]
        , arguments =
            [ CodeGen.Argument.new "model"
            , CodeGen.Argument.new "effect"
            ]
        , expression =
            CodeGen.Expression.multilineFunction
                { name = "Effect.toCmd"
                , arguments =
                    [ CodeGen.Expression.multilineRecord
                        [ ( "key", CodeGen.Expression.value "model.key" )
                        , ( "url", CodeGen.Expression.value "model.url" )
                        , ( "shared", CodeGen.Expression.value "model.shared" )
                        , ( "toMainMsg", CodeGen.Expression.value options.toMainMsg )
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
            ( "Msg_" ++ PageFile.toVariantName page
            , if PageFile.isSandboxOrElementElmLandPage page || PageFile.isAdvancedElmLandPage page then
                [ CodeGen.Annotation.type_ (PageFile.toModuleName page ++ ".Msg")
                ]

              else
                []
            )
    in
    List.concat
        [ List.map toCustomType pages
        , [ ( "Msg_NotFound_", [] ) ]
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
                                        , ( "url", CodeGen.Expression.value "model.url" )
                                        , ( "shared", CodeGen.Expression.value "model.shared" )
                                        , ( "fromSharedMsg", CodeGen.Expression.value "SharedSent" )
                                        , ( "toMainMsg", CodeGen.Expression.value "identity" )
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
                            , { name = "Auth.Action.ShowLoadingPage"
                              , arguments = [ CodeGen.Argument.new "loadingView" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "Loading loadingView"
                                        , CodeGen.Expression.value "Cmd.none"
                                        ]
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
                            , { name = "Auth.Action.LoadExternalUrl"
                              , arguments = [ CodeGen.Argument.new "externalUrl" ]
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "Redirecting"
                                        , CodeGen.Expression.value "Browser.Navigation.load externalUrl"
                                        ]
                              }
                            ]
                        }
                }
        }


toViewCaseExpression : List LayoutFile -> CodeGen.Expression
toViewCaseExpression layouts =
    let
        toViewBranch : LayoutFile -> CodeGen.Expression.Branch
        toViewBranch filepath =
            { name = "Just"
            , arguments =
                [ CodeGen.Argument.new
                    ("(LayoutModel{{name}} layout)"
                        |> String.replace "{{name}}" (LayoutFile.toVariantName filepath)
                    )
                ]
            , expression =
                CodeGen.Expression.multilineFunction
                    { name = "Layout.view"
                    , arguments =
                        [ CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = LayoutFile.toModuleName filepath ++ ".layout"
                                , arguments =
                                    [ CodeGen.Expression.value "layout.settings model.shared (Route.fromUrl () model.url)"
                                    ]
                                }
                            ]
                        , CodeGen.Expression.multilineRecord
                            [ ( "model", CodeGen.Expression.value "layout.model" )
                            , ( "toMainMsg"
                              , "LayoutMsg_{{name}} >> LayoutSent"
                                    |> String.replace "{{name}}" (LayoutFile.toVariantName filepath)
                                    |> CodeGen.Expression.value
                              )
                            , ( "content", CodeGen.Expression.value "viewPage model" )
                            ]
                        ]
                    }
            }
    in
    if List.isEmpty layouts then
        CodeGen.Expression.value "viewPage model"

    else
        CodeGen.Expression.caseExpression
            { value = CodeGen.Argument.new "model.layout"
            , branches =
                List.map toViewBranch layouts
                    ++ [ { name = "Nothing"
                         , arguments = []
                         , expression = CodeGen.Expression.value "viewPage model"
                         }
                       ]
            }


toViewPageCaseExpression : List PageFile -> CodeGen.Expression
toViewPageCaseExpression pages =
    let
        toViewBranch : PageFile -> CodeGen.Expression.Branch
        toViewBranch page =
            if PageFile.isSandboxOrElementElmLandPage page then
                toBranchForElmLandPage False page

            else if PageFile.isAdvancedElmLandPage page then
                toBranchForElmLandPage True page

            else
                toBranchForStaticPage page

        toBranchForElmLandPage : Bool -> PageFile -> CodeGen.Expression.Branch
        toBranchForElmLandPage isAdvancedElmLandPage page =
            { name = "PageModel" ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                toPageModelMapper
                    { page = page
                    , isAdvancedElmLandPage = isAdvancedElmLandPage
                    , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                    , function = "view"
                    , mapper = "View.map"
                    }
                    |> conditionallyWrapInAuthView page
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

        toBranchForStaticPage : PageFile -> CodeGen.Expression.Branch
        toBranchForStaticPage page =
            { name = "PageModel" ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                callSandboxOrElementPageFunction page
                    |> conditionallyWrapInAuthView page
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


toPageModelArgs : PageFile -> List CodeGen.Argument.Argument
toPageModelArgs page =
    List.concat
        [ if PageFile.hasDynamicParameters page then
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

        toBranchForStaticPage : PageFile -> CodeGen.Expression.Branch
        toBranchForStaticPage page =
            { name =
                "( Msg_{{name}}, PageModel{{name}}{{args}} )"
                    |> String.replace "{{name}}" (PageFile.toVariantName page)
                    |> String.replace "{{args}}"
                        (case toPageModelArgs page of
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

        toBranchForSandboxOrElementElmLandPage : PageFile -> CodeGen.Expression.Branch
        toBranchForSandboxOrElementElmLandPage page =
            { name =
                "( Msg_{{name}} pageMsg, PageModel{{name}} {{args}} )"
                    |> String.replace "{{name}}" (PageFile.toVariantName page)
                    |> String.replace "{{args}}"
                        (toPageModelArgs page
                            |> List.map CodeGen.Argument.toString
                            |> String.join " "
                        )
            , arguments = []
            , expression =
                CodeGen.Expression.multilineFunction
                    { name = "Tuple.mapBoth"
                    , arguments =
                        [ pageModelConstructor page
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Effect.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("Msg_" ++ PageFile.toVariantName page)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromPageEffect model"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Page.update"
                                , arguments =
                                    [ callSandboxOrElementPageFunction page
                                    , CodeGen.Expression.value "pageMsg"
                                    , CodeGen.Expression.value "pageModel"
                                    ]
                                }
                            ]
                        ]
                    }
                    |> conditionallyWrapInRunWhenAuthenticated page
            }

        toBranchForAdvancedElmLandPage : PageFile -> CodeGen.Expression.Branch
        toBranchForAdvancedElmLandPage page =
            { name =
                "( Msg_{{name}} pageMsg, PageModel{{name}} {{args}} )"
                    |> String.replace "{{name}}" (PageFile.toVariantName page)
                    |> String.replace "{{args}}"
                        (toPageModelArgs page
                            |> List.map CodeGen.Argument.toString
                            |> String.join " "
                        )
            , arguments = []
            , expression =
                CodeGen.Expression.multilineFunction
                    { name = "Tuple.mapBoth"
                    , arguments =
                        [ pageModelConstructor page
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Effect.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("Msg_" ++ PageFile.toVariantName page)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromPageEffect model"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Page.update"
                                , arguments =
                                    [ CodeGen.Expression.parens [ callAdvancedPageFunction page "model.url" ]
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
            if PageFile.isSandboxOrElementElmLandPage page then
                toBranchForSandboxOrElementElmLandPage page

            else if PageFile.isAdvancedElmLandPage page then
                toBranchForAdvancedElmLandPage page

            else
                toBranchForStaticPage page
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


toUpdateLayoutCaseExpression : List LayoutFile -> CodeGen.Expression
toUpdateLayoutCaseExpression layouts =
    let
        defaultCaseBranch : CodeGen.Expression.Branch
        defaultCaseBranch =
            { name = "_"
            , arguments = []
            , expression =
                CodeGen.Expression.multilineTuple
                    [ CodeGen.Expression.value "model.layout"
                    , CodeGen.Expression.value "Cmd.none"
                    ]
            }

        toBranch : LayoutFile -> CodeGen.Expression.Branch
        toBranch layout =
            { name =
                "( LayoutMsg_{{name}} layoutMsg, Just (LayoutModel_{{name}} layout) )"
                    |> String.replace "{{name}}" (LayoutFile.toVariantName layout)
            , arguments = []
            , expression =
                CodeGen.Expression.multilineFunction
                    { name = "Tuple.mapBoth"
                    , arguments =
                        [ layoutModelConstructor layout
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Effect.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("LayoutMsg_" ++ LayoutFile.toVariantName layout)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromLayoutEffect model"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Layout.update"
                                , arguments =
                                    [ CodeGen.Expression.parens [ callLayoutFunction layout ]
                                    , CodeGen.Expression.value "layoutMsg"
                                    , CodeGen.Expression.value "layout.model"
                                    ]
                                }
                            ]
                        ]
                    }

            -- |> conditionallyWrapInRunWhenAuthenticated page
            }
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "( msg, model.layout )"
        , branches = List.map toBranch layouts ++ [ defaultCaseBranch ]
        }


{-| Example: (Layouts.Sidebar.layout layout.settings model.shared (Route.fromUrl () model.url))
-}
callLayoutFunction : LayoutFile -> CodeGen.Expression
callLayoutFunction layout =
    "{{moduleName}}.layout layout.settings model.shared (Route.fromUrl () model.url)"
        |> String.replace "{{moduleName}}" (LayoutFile.toModuleName layout)
        |> CodeGen.Expression.value


toSubscriptionPageCaseExpression : List PageFile -> CodeGen.Expression.Expression
toSubscriptionPageCaseExpression pages =
    let
        toBranchForStaticPage : PageFile -> CodeGen.Expression.Branch
        toBranchForStaticPage page =
            { name = "PageModel" ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression = CodeGen.Expression.value "Sub.none"
            }

        toBranchForElmLandPage : Bool -> PageFile -> CodeGen.Expression.Branch
        toBranchForElmLandPage isAdvancedElmLandPage page =
            { name = "PageModel" ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                toPageModelMapper
                    { isAdvancedElmLandPage = isAdvancedElmLandPage
                    , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                    , page = page
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
            if PageFile.isSandboxOrElementElmLandPage page then
                toBranchForElmLandPage False page

            else if PageFile.isAdvancedElmLandPage page then
                toBranchForElmLandPage True page

            else
                toBranchForStaticPage page
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


toSubscriptionLayoutCaseExpression : List LayoutFile -> CodeGen.Expression.Expression
toSubscriptionLayoutCaseExpression layouts =
    let
        toBranch : LayoutFile -> CodeGen.Expression.Branch
        toBranch layout =
            { name = "Just"
            , arguments =
                [ "(LayoutModel{{name}} layout)"
                    |> String.replace "{{name}}" (LayoutFile.toVariantName layout)
                    |> CodeGen.Argument.new
                ]
            , expression =
                CodeGen.Expression.pipeline
                    [ CodeGen.Expression.function
                        { name = "Layout.subscriptions"
                        , arguments =
                            [ CodeGen.Expression.parens [ callLayoutFunction layout ]
                            , CodeGen.Expression.value "layout.model"
                            ]
                        }
                    , CodeGen.Expression.value ("Sub.map LayoutMsg_" ++ LayoutFile.toVariantName layout)
                    , CodeGen.Expression.value "Sub.map LayoutSent"
                    ]
            }
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "model.layout"
        , branches =
            List.concat
                [ List.map toBranch layouts
                , [ { name = "Nothing"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  ]
                ]
        }


toInitLayoutCaseExpression : List LayoutFile -> CodeGen.Expression.Expression
toInitLayoutCaseExpression layouts =
    let
        toBranch : LayoutFile -> List CodeGen.Expression.Branch
        toBranch layout =
            let
                moduleName : String
                moduleName =
                    LayoutFile.toModuleName layout

                routeVariantName : String
                routeVariantName =
                    LayoutFile.toVariantName layout

                modelVariantName : String
                modelVariantName =
                    "LayoutModel_" ++ routeVariantName

                msgVariantName : String
                msgVariantName =
                    "LayoutMsg_" ++ routeVariantName

                initLayoutBranchExpression : CodeGen.Expression
                initLayoutBranchExpression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "( layoutModel, layoutCmd )"
                              , annotation = Nothing
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Layout.init"
                                        , arguments =
                                            [ CodeGen.Expression.parens
                                                [ CodeGen.Expression.function
                                                    { name = moduleName ++ ".layout"
                                                    , arguments =
                                                        [ CodeGen.Expression.value "settings model.shared (Route.fromUrl () model.url)"
                                                        ]
                                                    }
                                                ]
                                            , CodeGen.Expression.tuple []
                                            ]
                                        }
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.multilineTuple
                                [ CodeGen.Expression.function
                                    { name = modelVariantName
                                    , arguments = [ CodeGen.Expression.value "layoutModel" ]
                                    }
                                , CodeGen.Expression.value ("fromLayoutEffect model (Effect.map " ++ msgVariantName ++ " layoutCmd)")
                                ]
                        }

                reuseExistingBranchExpression : CodeGen.Expression
                reuseExistingBranchExpression =
                    CodeGen.Expression.multilineTuple
                        [ "{{modelVariantName}} existing"
                            |> String.replace "{{modelVariantName}}" modelVariantName
                            |> CodeGen.Expression.value
                        , CodeGen.Expression.value "Cmd.none"
                        ]
            in
            [ { name =
                    "( Just ({{modelVariantName}} existing), Layouts.{{routeVariantName}} settings )"
                        |> String.replace "{{routeVariantName}}" routeVariantName
                        |> String.replace "{{modelVariantName}}" modelVariantName
              , arguments = []
              , expression = reuseExistingBranchExpression
              }
            , { name = "( _, Layouts.{{routeVariantName}} settings )" |> String.replace "{{routeVariantName}}" routeVariantName
              , arguments = []
              , expression = initLayoutBranchExpression
              }
            ]
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "( model.layout, layout )"
        , branches = List.concatMap toBranch layouts
        }


toInitPageCaseExpression : List PageFile -> CodeGen.Expression.Expression
toInitPageCaseExpression pages =
    let
        toBranchExpressionForStaticPage : PageFile -> CodeGen.Expression
        toBranchExpressionForStaticPage page =
            CodeGen.Expression.multilineRecord
                [ ( "page"
                  , CodeGen.Expression.tuple
                        [ pageModelConstructor page
                        , CodeGen.Expression.value "Cmd.none"
                        ]
                  )
                , ( "layout", CodeGen.Expression.value "Nothing" )
                ]

        toBranchForSandboxOrElementElmLandPage : PageFile -> CodeGen.Expression
        toBranchForSandboxOrElementElmLandPage page =
            CodeGen.Expression.multilineRecord
                [ ( "page"
                  , CodeGen.Expression.multilineFunction
                        { name = "Tuple.mapBoth"
                        , arguments =
                            [ pageModelConstructor page
                            , CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "Effect.map"
                                    , arguments =
                                        [ CodeGen.Expression.value ("Msg_" ++ PageFile.toVariantName page)
                                        ]
                                    }
                                , CodeGen.Expression.operator ">>"
                                , CodeGen.Expression.value "fromPageEffect model"
                                ]
                            , CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "Page.init"
                                    , arguments =
                                        [ callSandboxOrElementPageFunction page
                                        , CodeGen.Expression.value "()"
                                        ]
                                    }
                                ]
                            ]
                        }
                  )
                , ( "layout", CodeGen.Expression.value "Nothing" )
                ]

        toBranchForAdvancedElmLandPage : PageFile -> CodeGen.Expression
        toBranchForAdvancedElmLandPage page =
            let
                pageExpression =
                    CodeGen.Expression.multilineFunction
                        { name = "Tuple.mapBoth"
                        , arguments =
                            [ pageModelConstructor page
                            , CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "Effect.map"
                                    , arguments =
                                        [ CodeGen.Expression.value ("Msg_" ++ PageFile.toVariantName page)
                                        ]
                                    }
                                , CodeGen.Expression.operator ">>"
                                , CodeGen.Expression.value "fromPageEffect model"
                                ]
                            , CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "Page.init"
                                    , arguments =
                                        [ CodeGen.Expression.value "page"
                                        , CodeGen.Expression.value "()"
                                        ]
                                    }
                                ]
                            ]
                        }
            in
            CodeGen.Expression.letIn
                { let_ =
                    [ { argument = CodeGen.Argument.new "page"
                      , annotation =
                            Just
                                (CodeGen.Annotation.genericType "Page.Page"
                                    [ CodeGen.Annotation.type_ (PageFile.toModuleName page ++ ".Model")
                                    , CodeGen.Annotation.type_ (PageFile.toModuleName page ++ ".Msg")
                                    ]
                                )
                      , expression = callAdvancedPageFunction page "model.url"
                      }
                    ]
                , in_ =
                    CodeGen.Expression.multilineRecord
                        [ ( "page", pageExpression )
                        , ( "layout", CodeGen.Expression.value "Page.layout page |> Maybe.map (initLayout model)" )
                        ]
                }

        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            let
                branchExpression : CodeGen.Expression
                branchExpression =
                    conditionallyWrapInRunWhenAuthenticated page
                        (if PageFile.isSandboxOrElementElmLandPage page then
                            toBranchForSandboxOrElementElmLandPage page

                         else if PageFile.isAdvancedElmLandPage page then
                            toBranchForAdvancedElmLandPage page

                         else
                            toBranchExpressionForStaticPage page
                        )
            in
            if PageFile.hasDynamicParameters page then
                { name = "Route.Path." ++ PageFile.toVariantName page
                , arguments = [ CodeGen.Argument.new "params" ]
                , expression = branchExpression
                }

            else
                { name = "Route.Path." ++ PageFile.toVariantName page
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
                        CodeGen.Expression.multilineRecord
                            [ ( "page"
                              , CodeGen.Expression.tuple
                                    [ CodeGen.Expression.value "PageModelNotFound_"
                                    , CodeGen.Expression.value "Cmd.none"
                                    ]
                              )
                            , ( "layout", CodeGen.Expression.value "Nothing" )
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


pageModelConstructor : PageFile -> CodeGen.Expression
pageModelConstructor page =
    if PageFile.hasDynamicParameters page then
        CodeGen.Expression.parens
            [ CodeGen.Expression.function
                { name = "PageModel" ++ PageFile.toVariantName page
                , arguments = [ CodeGen.Expression.value "params" ]
                }
            ]

    else
        CodeGen.Expression.value ("PageModel" ++ PageFile.toVariantName page)


{-| Example:

    \newModel -> Just (LayoutModelSidebar { layout | model = newModel })

-}
layoutModelConstructor : LayoutFile -> CodeGen.Expression
layoutModelConstructor layout =
    CodeGen.Expression.lambda
        { arguments = [ CodeGen.Argument.new "newModel" ]
        , expression =
            "Just (LayoutModel_{{name}} { layout | model = newModel })"
                |> String.replace "{{name}}" (LayoutFile.toVariantName layout)
                |> CodeGen.Expression.value
        }


callSandboxOrElementPageFunction : PageFile -> CodeGen.Expression
callSandboxOrElementPageFunction page =
    let
        arguments : List CodeGen.Expression
        arguments =
            List.concat
                [ if PageFile.isAuthProtectedPage page then
                    [ CodeGen.Expression.value "user" ]

                  else
                    []
                , if PageFile.hasDynamicParameters page then
                    [ CodeGen.Expression.value "params" ]

                  else
                    []
                ]
    in
    CodeGen.Expression.parens
        [ CodeGen.Expression.function
            { name = PageFile.toModuleName page ++ ".page"
            , arguments = arguments
            }
        ]


callAdvancedPageFunction : PageFile -> String -> CodeGen.Expression
callAdvancedPageFunction page urlVarName =
    CodeGen.Expression.function
        { name = PageFile.toModuleName page ++ ".page"
        , arguments =
            [ if PageFile.isAuthProtectedPage page then
                CodeGen.Expression.value "user model.shared"

              else
                CodeGen.Expression.value "model.shared"
            , if PageFile.hasDynamicParameters page then
                CodeGen.Expression.value ("(Route.fromUrl params " ++ urlVarName ++ ")")

              else
                CodeGen.Expression.value ("(Route.fromUrl () " ++ urlVarName ++ ")")
            ]
        }


toPageModelMapper :
    { isAdvancedElmLandPage : Bool
    , isAuthProtectedPage : Bool
    , page : PageFile
    , function : String
    , mapper : String
    }
    -> CodeGen.Expression
toPageModelMapper options =
    let
        pageModuleName : String
        pageModuleName =
            PageFile.toModuleName options.page

        routeVariantName : String
        routeVariantName =
            PageFile.toVariantName options.page
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
                        , if PageFile.hasDynamicParameters options.page then
                            CodeGen.Expression.value "(Route.fromUrl params model.url)"

                          else
                            CodeGen.Expression.value "(Route.fromUrl () model.url)"
                        ]

                  else if PageFile.hasDynamicParameters options.page then
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
                            |> List.map PageFile.toRouteVariant
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
                                |> List.map PageFile.toUrlParser
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
toRoutePathToStringBranch page =
    { name = PageFile.toVariantName page
    , arguments =
        if PageFile.hasDynamicParameters page then
            [ CodeGen.Argument.new "params" ]

        else
            []
    , expression =
        if PageFile.toVariantName page == "Home_" then
            CodeGen.Expression.list []

        else
            CodeGen.Expression.list
                (PageFile.toList page
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

    module Layouts exposing (Layout(..))

    import Layouts.Default
    import Layouts.Sidebar

    type Layout
        = Default Layouts.Default.Settings
        | Sidebar Layouts.Sidebar.Settings

-}
layoutsElmModule : Data -> CodeGen.Module
layoutsElmModule data =
    let
        toLayoutImport : LayoutFile -> CodeGen.Import
        toLayoutImport layout =
            CodeGen.Import.new
                (LayoutFile.toModuleName layout
                    |> String.split "."
                )
    in
    CodeGen.Module.new
        { name = [ "Layouts" ]
        , exposing_ = [ "Layout(..)" ]
        , imports = List.map toLayoutImport data.layouts
        , declarations =
            [ LayoutFile.toLayoutTypeDeclaration data.layouts
            ]
        }


{-| This represents the data we expect to receive from JavaScript
-}
type alias Data =
    { pages : List PageFile
    , layouts : List LayoutFile
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map2 Data
        (Json.Decode.field "pages"
            (Json.Decode.list PageFile.decoder
                |> Json.Decode.map ignoreNotFoundPage
            )
        )
        (Json.Decode.field "layouts" (Json.Decode.list LayoutFile.decoder)
            |> Json.Decode.map (List.sortWith LayoutFile.sorter)
        )


ignoreNotFoundPage : List PageFile -> List PageFile
ignoreNotFoundPage pageFiles =
    pageFiles
        |> List.filter (PageFile.isNotFoundPage >> not)
