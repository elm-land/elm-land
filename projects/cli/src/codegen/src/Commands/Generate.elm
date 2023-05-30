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
            List.concat
                [ [ mainElmModule data
                  , mainPagesModelModule data
                  , mainPagesMsgModule data
                  , mainLayoutsModelModule data
                  , mainLayoutsMsgModule data
                  , routePathElmModule data
                  , routeQueryElmModule data
                  , routeElmModule data
                  , layoutsElmModule data
                  ]
                , if data.options.useHashRouting then
                    [ hashRoutingElmModule ]

                  else
                    []
                ]

        Err _ ->
            -- TODO: Better handling here now that input can come from users
            []


mainPagesModelModule : Data -> CodeGen.Module
mainPagesModelModule data =
    CodeGen.Module.new
        { name = [ "Main", "Pages", "Model" ]
        , exposing_ = [ "Model(..)" ]
        , imports =
            List.concat
                [ data.pages
                    |> List.map PageFile.toList
                    |> List.map (\pieces -> "Pages" :: pieces)
                    |> List.map CodeGen.Import.new
                , [ CodeGen.Import.new [ "View" ] |> CodeGen.Import.withExposing [ "View" ] ]
                ]
        , declarations =
            [ PageFile.toPageModelTypeDeclaration data.pages
            ]
        }


mainPagesMsgModule : Data -> CodeGen.Module
mainPagesMsgModule data =
    CodeGen.Module.new
        { name = [ "Main", "Pages", "Msg" ]
        , exposing_ = [ "Msg(..)" ]
        , imports =
            data.pages
                |> List.map PageFile.toList
                |> List.map (\pieces -> "Pages" :: pieces)
                |> List.map CodeGen.Import.new
        , declarations =
            [ CodeGen.Declaration.customType
                { name = "Msg"
                , variants = toPageMsgCustomType data.pages
                }
            ]
        }


mainLayoutsModelModule : Data -> CodeGen.Module
mainLayoutsModelModule data =
    CodeGen.Module.new
        { name = [ "Main", "Layouts", "Model" ]
        , exposing_ = [ ".." ]
        , imports =
            data.layouts
                |> List.map LayoutFile.toList
                |> List.map (\pieces -> "Layouts" :: pieces)
                |> List.map CodeGen.Import.new
        , declarations =
            [ LayoutFile.toLayoutsModelTypeDeclaration data.layouts
            ]
        }


mainLayoutsMsgModule : Data -> CodeGen.Module
mainLayoutsMsgModule data =
    CodeGen.Module.new
        { name = [ "Main", "Layouts", "Msg" ]
        , exposing_ = [ ".." ]
        , imports =
            data.layouts
                |> List.map LayoutFile.toList
                |> List.map (\pieces -> "Layouts" :: pieces)
                |> List.map CodeGen.Import.new
        , declarations =
            [ LayoutFile.toLayoutsMsgTypeDeclaration data.layouts
            ]
        }


mainElmModule : Data -> CodeGen.Module
mainElmModule data =
    CodeGen.Module.new
        { name = [ "Main" ]
        , exposing_ = [ ".." ]
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
                  , CodeGen.Import.new [ "Layout" ]
                  , CodeGen.Import.new [ "Layouts" ]
                  ]
                , data.layouts
                    |> List.map LayoutFile.toList
                    |> List.map (\pieces -> "Layouts" :: pieces)
                    |> List.map CodeGen.Import.new
                , [ CodeGen.Import.new [ "Main", "Layouts", "Model" ]
                  , CodeGen.Import.new [ "Main", "Layouts", "Msg" ]
                  , CodeGen.Import.new [ "Main", "Pages", "Model" ]
                  , CodeGen.Import.new [ "Main", "Pages", "Msg" ]
                  , CodeGen.Import.new [ "Page" ]
                  ]
                , data.pages
                    |> List.map PageFile.toList
                    |> List.map (\pieces -> "Pages" :: pieces)
                    |> List.map CodeGen.Import.new
                , [ CodeGen.Import.new [ "Pages", "NotFound_" ]
                  , CodeGen.Import.new [ "Route" ] |> CodeGen.Import.withExposing [ "Route" ]
                  , CodeGen.Import.new [ "Route", "Path" ]
                  , CodeGen.Import.new [ "Shared" ]
                  , CodeGen.Import.new [ "Task" ]
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
                        , ( "page", CodeGen.Annotation.type_ "Main.Pages.Model.Model" )
                        , ( "layout", CodeGen.Annotation.type_ "Maybe Main.Layouts.Model.Model" )
                        , ( "shared", CodeGen.Annotation.type_ "Shared.Model" )
                        ]
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
                                , ( "layout", CodeGen.Annotation.type_ "Maybe Main.Layouts.Model.Model" )
                                ]
                            , CodeGen.Annotation.type_ "Layouts.Layout Msg"
                            , CodeGen.Annotation.type_ "( Main.Layouts.Model.Model, Cmd Msg )"
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
                            , ( "layout", CodeGen.Annotation.type_ "Maybe Main.Layouts.Model.Model" )
                            ]
                        , CodeGen.Annotation.type_ "{ page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression = toInitPageCaseExpression data.layouts data.pages
                }
            , runWhenAuthenticatedDeclaration
            , runWhenAuthenticatedWithLayoutDeclaration
            , CodeGen.Declaration.comment [ "UPDATE" ]
            , CodeGen.Declaration.customType
                { name = "Msg"
                , variants =
                    [ ( "UrlRequested", [ CodeGen.Annotation.type_ "Browser.UrlRequest" ] )
                    , ( "UrlChanged", [ CodeGen.Annotation.type_ "Url" ] )
                    , ( "PageSent", [ CodeGen.Annotation.type_ "Main.Pages.Msg.Msg" ] )
                    , ( "LayoutSent", [ CodeGen.Annotation.type_ "Main.Layouts.Msg.Msg" ] )
                    , ( "SharedSent", [ CodeGen.Annotation.type_ "Shared.Msg" ] )
                    , ( "Batch", [ CodeGen.Annotation.type_ "(List Msg)" ] )
                    ]
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
                                    let
                                        whenOnSamePage : CodeGen.Expression
                                        whenOnSamePage =
                                            CodeGen.Expression.letIn
                                                { let_ =
                                                    [ { argument = CodeGen.Argument.new "newModel"
                                                      , annotation = Just (CodeGen.Annotation.type_ "Model")
                                                      , expression =
                                                            CodeGen.Expression.value "{ model | url = url }"
                                                      }
                                                    ]
                                                , in_ =
                                                    CodeGen.Expression.multilineTuple
                                                        [ CodeGen.Expression.value "newModel"
                                                        , CodeGen.Expression.multilineFunction
                                                            { name = "toPageUrlMessageCmd newModel"
                                                            , arguments =
                                                                [ CodeGen.Expression.multilineRecord
                                                                    [ ( "before", CodeGen.Expression.value "Route.fromUrl () model.url" )
                                                                    , ( "after", CodeGen.Expression.value "Route.fromUrl () newModel.url" )
                                                                    ]
                                                                ]
                                                            }
                                                        ]
                                                }
                                    in
                                    CodeGen.Expression.ifElse
                                        { condition = CodeGen.Expression.value "Route.Path.fromUrl url == Route.Path.fromUrl model.url"
                                        , ifBranch = whenOnSamePage
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
                                                                    [ { argument = CodeGen.Argument.new "{ layout, page }"
                                                                      , annotation = Nothing
                                                                      , expression =
                                                                            CodeGen.Expression.value "initPageAndLayout { key = model.key, shared = sharedModel, url = model.url, layout = model.layout }"
                                                                      }
                                                                    , { argument = CodeGen.Argument.new "( pageModel, pageCmd )"
                                                                      , annotation = Nothing
                                                                      , expression = CodeGen.Expression.value "page"
                                                                      }
                                                                    , { argument = CodeGen.Argument.new "( layoutModel, layoutCmd )"
                                                                      , annotation = Nothing
                                                                      , expression =
                                                                            CodeGen.Expression.multilineTuple
                                                                                [ CodeGen.Expression.value "layout |> Maybe.map Tuple.first"
                                                                                , CodeGen.Expression.value "layout |> Maybe.map Tuple.second |> Maybe.withDefault Cmd.none"
                                                                                ]
                                                                      }
                                                                    ]
                                                                , in_ =
                                                                    CodeGen.Expression.multilineTuple
                                                                        [ CodeGen.Expression.value "{ model | shared = sharedModel, page = pageModel, layout = layoutModel }"
                                                                        , CodeGen.Expression.multilineFunction
                                                                            { name = "Cmd.batch"
                                                                            , arguments =
                                                                                [ CodeGen.Expression.multilineList
                                                                                    [ CodeGen.Expression.value "pageCmd"
                                                                                    , CodeGen.Expression.value "layoutCmd"
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
                            , { name = "Batch messages"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.multilineTuple
                                        [ CodeGen.Expression.value "model"
                                        , CodeGen.Expression.pipeline
                                            [ CodeGen.Expression.value "messages"
                                            , CodeGen.Expression.value "List.map (Task.succeed >> Task.perform identity)"
                                            , CodeGen.Expression.value "Cmd.batch"
                                            ]
                                        ]
                              }
                            ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "updateFromPage"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Main.Pages.Msg.Msg"
                        , CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "( Main.Pages.Model.Model, Cmd Msg )"
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
                        [ CodeGen.Annotation.type_ "Main.Layouts.Msg.Msg"
                        , CodeGen.Annotation.type_ "Model"
                        , CodeGen.Annotation.type_ "( Maybe Main.Layouts.Model.Model, Cmd Msg )"
                        ]
                , arguments =
                    [ CodeGen.Argument.new "msg"
                    , CodeGen.Argument.new "model"
                    ]
                , expression = toUpdateLayoutCaseExpression data.layouts
                }
            , toLayoutFromPageDeclaration data.pages
            , toAuthProtectedPageDeclaration
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
                            , { argument = CodeGen.Argument.new "maybeLayout"
                              , annotation = Just (CodeGen.Annotation.type_ "Maybe (Layouts.Layout Msg)")
                              , expression = CodeGen.Expression.value "toLayoutFromPage model"
                              }
                            , { argument = CodeGen.Argument.new "route"
                              , annotation = Just (CodeGen.Annotation.type_ "Route ()")
                              , expression = CodeGen.Expression.value "Route.fromUrl () model.url"
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
                                                    [ CodeGen.Expression.value "route"
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
                        , CodeGen.Annotation.type_ "Browser.Document Msg"
                        ]
                , arguments = [ CodeGen.Argument.new "model" ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "view_"
                              , annotation = Just (CodeGen.Annotation.type_ "View Msg")
                              , expression = CodeGen.Expression.value "toView model"
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.multilineFunction
                                { name = "View.toBrowserDocument"
                                , arguments =
                                    [ CodeGen.Expression.multilineRecord
                                        [ ( "shared", CodeGen.Expression.value "model.shared" )
                                        , ( "route", CodeGen.Expression.value "Route.fromUrl () model.url" )
                                        , ( "view", CodeGen.Expression.value "view_" )
                                        ]
                                    ]
                                }
                        }
                }
            , CodeGen.Declaration.function
                { name = "toView"
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
                , msgType = "Main.Pages.Msg.Msg"
                , toContentMsg = "PageSent"
                }
            , fromEffectDeclaration
                { name = "fromLayoutEffect"
                , msgType = "Main.Layouts.Msg.Msg"
                , toContentMsg = "LayoutSent"
                }
            , fromEffectDeclaration
                { name = "fromSharedEffect"
                , msgType = "Shared.Msg"
                , toContentMsg = "SharedSent"
                }
            , CodeGen.Declaration.comment [ "URL HOOKS FOR PAGES" ]
            , CodeGen.Declaration.function
                { name = "toPageUrlMessageCmd"
                , annotation = CodeGen.Annotation.type_ "Model -> { before : Route (), after : Route () } -> Cmd Msg"
                , arguments = List.map CodeGen.Argument.new [ "model", "routes" ]
                , expression = toPageUrlMessageCmd data.pages
                }
            ]
        }


toPageUrlMessageCmd : List PageFile -> CodeGen.Expression.Expression
toPageUrlMessageCmd pages =
    let
        toBranchForStaticPage : PageFile -> CodeGen.Expression.Branch
        toBranchForStaticPage page =
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression = CodeGen.Expression.value "Cmd.none"
            }

        toBranchForElmLandPage : Bool -> PageFile -> CodeGen.Expression.Branch
        toBranchForElmLandPage isAdvancedElmLandPage page =
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                CodeGen.Expression.pipeline
                    [ toPageModelMapper
                        { isAdvancedElmLandPage = isAdvancedElmLandPage
                        , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                        , page = page
                        , function = "toUrlMessages routes"
                        , hasPageModelArg = False
                        , mapper = "List.map"
                        }
                    , CodeGen.Expression.value "toCommands"
                    ]
                    |> conditionallyWrapInAuthAction page
            }

        conditionallyWrapInAuthAction : PageFile -> CodeGen.Expression -> CodeGen.Expression
        conditionallyWrapInAuthAction page expression =
            if PageFile.isAuthProtectedPage page then
                CodeGen.Expression.multilineFunction
                    { name = "Auth.Action.command"
                    , arguments =
                        [ CodeGen.Expression.multilineLambda
                            { arguments = [ CodeGen.Argument.new "user" ]
                            , expression = expression
                            }
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
    CodeGen.Expression.letIn
        { let_ =
            [ { argument = CodeGen.Argument.new "toCommands messages"
              , annotation = Nothing
              , expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.value "messages"
                        , CodeGen.Expression.value "List.map (Task.succeed >> Task.perform identity)"
                        , CodeGen.Expression.value "Cmd.batch"
                        ]
              }
            ]
        , in_ =
            CodeGen.Expression.caseExpression
                { value = CodeGen.Argument.new "model.page"
                , branches =
                    List.concat
                        [ List.map toBranch pages
                        , [ { name = "Main.Pages.Model.Redirecting_"
                            , arguments = []
                            , expression = CodeGen.Expression.value "Cmd.none"
                            }
                          , { name = "Main.Pages.Model.Loading_"
                            , arguments = []
                            , expression = CodeGen.Expression.value "Cmd.none"
                            }
                          ]
                        ]
                }
        }


fromEffectDeclaration :
    { name : String
    , msgType : String
    , toContentMsg : String
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
                        , ( "fromSharedMsg", CodeGen.Expression.value "SharedSent" )
                        , ( "batch", CodeGen.Expression.value "Batch" )
                        , ( "toCmd", CodeGen.Expression.value "Task.succeed >> Task.perform identity" )
                        ]
                    , CodeGen.Expression.parens
                        [ CodeGen.Expression.function
                            { name = "Effect.map"
                            , arguments =
                                [ CodeGen.Expression.value options.toContentMsg
                                , CodeGen.Expression.value "effect"
                                ]
                            }
                        ]
                    ]
                }
        }


toLayoutFromPageDeclaration : List PageFile -> CodeGen.Declaration
toLayoutFromPageDeclaration pages =
    let
        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                if PageFile.isAdvancedElmLandPage page then
                    if PageFile.isAuthProtectedPage page then
                        CodeGen.Expression.pipeline
                            [ if PageFile.hasDynamicParameters page then
                                CodeGen.Expression.value "Route.fromUrl params model.url"

                              else
                                CodeGen.Expression.value "Route.fromUrl () model.url"
                            , CodeGen.Expression.value ("toAuthProtectedPage model {{moduleName}}.page" |> String.replace "{{moduleName}}" (PageFile.toModuleName page))
                            , CodeGen.Expression.value "Maybe.andThen (Page.layout pageModel)"
                            , CodeGen.Expression.value
                                ("Maybe.map (Layouts.map ({{msgVariant}} >> PageSent))"
                                    |> String.replace "{{msgVariant}}" ("Main.Pages.Msg." ++ PageFile.toVariantName page)
                                )
                            ]

                    else
                        CodeGen.Expression.pipeline
                            [ if PageFile.hasDynamicParameters page then
                                CodeGen.Expression.value "Route.fromUrl params model.url"

                              else
                                CodeGen.Expression.value "Route.fromUrl () model.url"
                            , CodeGen.Expression.value ("{{moduleName}}.page model.shared" |> String.replace "{{moduleName}}" (PageFile.toModuleName page))
                            , CodeGen.Expression.value "Page.layout pageModel"
                            , CodeGen.Expression.value
                                ("Maybe.map (Layouts.map ({{msgVariant}} >> PageSent))"
                                    |> String.replace "{{msgVariant}}" ("Main.Pages.Msg." ++ PageFile.toVariantName page)
                                )
                            ]

                else
                    CodeGen.Expression.value "Nothing"
            }

        toNothingBranch : String -> CodeGen.Expression.Branch
        toNothingBranch name =
            { name = "Main.Pages.Model." ++ name
            , arguments = []
            , expression = CodeGen.Expression.value "Nothing"
            }
    in
    CodeGen.Declaration.function
        { name = "toLayoutFromPage"
        , annotation = CodeGen.Annotation.type_ "Model -> Maybe (Layouts.Layout Msg)"
        , arguments = [ CodeGen.Argument.new "model" ]
        , expression =
            CodeGen.Expression.caseExpression
                { value = CodeGen.Argument.new "model.page"
                , branches =
                    List.map toBranch pages
                        ++ List.map toNothingBranch [ "Redirecting_", "Loading_" ]
                }
        }


toAuthProtectedPageDeclaration : CodeGen.Declaration
toAuthProtectedPageDeclaration =
    CodeGen.Declaration.function
        { name = "toAuthProtectedPage"
        , annotation = CodeGen.Annotation.type_ "Model -> (Auth.User -> Shared.Model -> Route params -> Page.Page model msg) -> Route params -> Maybe (Page.Page model msg)"
        , arguments = [ CodeGen.Argument.new "model", CodeGen.Argument.new "toPage", CodeGen.Argument.new "route" ]
        , expression =
            CodeGen.Expression.caseExpression
                { value = CodeGen.Argument.new "Auth.onPageLoad model.shared (Route.fromUrl () model.url)"
                , branches =
                    [ { name = "Auth.Action.LoadPageWithUser user"
                      , arguments = []
                      , expression = CodeGen.Expression.value "Just (toPage user model.shared route)"
                      }
                    , { name = "_"
                      , arguments = []
                      , expression = CodeGen.Expression.value "Nothing"
                      }
                    ]
                }
        }


toPageMsgCustomType : List PageFile -> List ( String, List CodeGen.Annotation )
toPageMsgCustomType pages =
    let
        toCustomType : PageFile -> ( String, List CodeGen.Annotation.Annotation )
        toCustomType page =
            ( PageFile.toVariantName page
            , if PageFile.isSandboxOrElementElmLandPage page || PageFile.isAdvancedElmLandPage page then
                [ CodeGen.Annotation.type_ (PageFile.toModuleName page ++ ".Msg")
                ]

              else
                []
            )
    in
    List.map toCustomType pages


runWhenAuthenticatedDeclaration : CodeGen.Declaration
runWhenAuthenticatedDeclaration =
    CodeGen.Declaration.function
        { name = "runWhenAuthenticated"
        , annotation =
            CodeGen.Annotation.function
                [ CodeGen.Annotation.type_ "{ model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key }"
                , CodeGen.Annotation.type_ "(Auth.User -> ( Main.Pages.Model.Model, Cmd Msg ))"
                , CodeGen.Annotation.type_ "( Main.Pages.Model.Model, Cmd Msg )"
                ]
        , arguments = [ CodeGen.Argument.new "model", CodeGen.Argument.new "toTuple" ]
        , expression =
            CodeGen.Expression.letIn
                { let_ =
                    [ { argument = CodeGen.Argument.new "record"
                      , annotation = Nothing
                      , expression = CodeGen.Expression.value "runWhenAuthenticatedWithLayout model (\\user -> { page = toTuple user, layout = Nothing })"
                      }
                    ]
                , in_ = CodeGen.Expression.value "record.page"
                }
        }


runWhenAuthenticatedWithLayoutDeclaration : CodeGen.Declaration
runWhenAuthenticatedWithLayoutDeclaration =
    let
        wrapInPageLayout : CodeGen.Expression -> CodeGen.Expression
        wrapInPageLayout expression =
            CodeGen.Expression.multilineRecord
                [ ( "page", expression )
                , ( "layout", CodeGen.Expression.value "Nothing" )
                ]
    in
    CodeGen.Declaration.function
        { name = "runWhenAuthenticatedWithLayout"
        , annotation =
            CodeGen.Annotation.function
                [ CodeGen.Annotation.type_ "{ model | shared : Shared.Model, url : Url, key : Browser.Navigation.Key }"
                , CodeGen.Annotation.type_ "(Auth.User -> { page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) })"
                , CodeGen.Annotation.type_ "{ page : ( Main.Pages.Model.Model, Cmd Msg ), layout : Maybe ( Main.Layouts.Model.Model, Cmd Msg ) }"
                ]
        , arguments = [ CodeGen.Argument.new "model", CodeGen.Argument.new "toRecord" ]
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
                                        , ( "batch", CodeGen.Expression.value "Batch" )
                                        , ( "toCmd", CodeGen.Expression.value "Task.succeed >> Task.perform identity" )
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
                              , expression = CodeGen.Expression.value "toRecord user"
                              }
                            , { name = "Auth.Action.ShowLoadingPage"
                              , arguments = [ CodeGen.Argument.new "loadingView" ]
                              , expression =
                                    wrapInPageLayout
                                        (CodeGen.Expression.multilineTuple
                                            [ CodeGen.Expression.value "Main.Pages.Model.Loading_"
                                            , CodeGen.Expression.value "Cmd.none"
                                            ]
                                        )
                              }
                            , { name = "Auth.Action.ReplaceRoute"
                              , arguments = [ CodeGen.Argument.new "options" ]
                              , expression =
                                    wrapInPageLayout <|
                                        CodeGen.Expression.multilineTuple
                                            [ CodeGen.Expression.value "Main.Pages.Model.Redirecting_"
                                            , CodeGen.Expression.value "toCmd (Effect.replaceRoute options)"
                                            ]
                              }
                            , { name = "Auth.Action.PushRoute"
                              , arguments = [ CodeGen.Argument.new "options" ]
                              , expression =
                                    wrapInPageLayout <|
                                        CodeGen.Expression.multilineTuple
                                            [ CodeGen.Expression.value "Main.Pages.Model.Redirecting_"
                                            , CodeGen.Expression.value "toCmd (Effect.pushRoute options)"
                                            ]
                              }
                            , { name = "Auth.Action.LoadExternalUrl"
                              , arguments = [ CodeGen.Argument.new "externalUrl" ]
                              , expression =
                                    wrapInPageLayout <|
                                        CodeGen.Expression.multilineTuple
                                            [ CodeGen.Expression.value "Main.Pages.Model.Redirecting_"
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
        toViewBranch layout =
            let
                selfAndParentLayouts : List LayoutFile
                selfAndParentLayouts =
                    LayoutFile.toListOfSelfAndParents layout
            in
            { name =
                "( Just (Layouts.{{name}} settings), Just (Main.Layouts.Model.{{name}} layoutModel) )"
                    |> String.replace "{{name}}" (LayoutFile.toVariantName layout)
            , arguments = []
            , expression = toViewBranchExpression True layout selfAndParentLayouts
            }

        toViewBranchExpression : Bool -> LayoutFile -> List LayoutFile -> CodeGen.Expression
        toViewBranchExpression isTopLevel original selfAndParentLayouts =
            let
                toNestedLayoutExpression : LayoutFile -> List LayoutFile -> CodeGen.Expression
                toNestedLayoutExpression current parents =
                    let
                        settings : String
                        settings =
                            if original == current then
                                "settings"

                            else
                                toLayoutPropsVariableName current
                    in
                    CodeGen.Expression.multilineFunction
                        { name = "Layout.view"
                        , arguments =
                            [ CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = LayoutFile.toModuleName current ++ ".layout"
                                    , arguments =
                                        [ "{{settings}} model.shared route"
                                            |> String.replace "{{settings}}" settings
                                            |> CodeGen.Expression.value
                                        ]
                                    }
                                ]
                            , CodeGen.Expression.multilineRecord
                                [ ( "model"
                                  , CodeGen.Expression.value
                                        ("layoutModel.{{lastPartFieldName}}"
                                            |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName current)
                                        )
                                  )
                                , ( "toContentMsg"
                                  , "Main.Layouts.Msg.{{name}} >> LayoutSent"
                                        |> String.replace "{{name}}" (LayoutFile.toVariantName current)
                                        |> CodeGen.Expression.value
                                  )
                                , ( "content", toViewBranchExpression False original parents )
                                ]
                            ]
                        }
            in
            case selfAndParentLayouts of
                [] ->
                    CodeGen.Expression.value "viewPage model"

                self :: parents ->
                    CodeGen.Expression.letIn
                        { let_ =
                            if isTopLevel then
                                List.map2
                                    (\child parent ->
                                        toParentLayoutProps
                                            { self = self
                                            , child = child
                                            , parent = parent
                                            }
                                    )
                                    (self :: parents)
                                    parents

                            else
                                []
                        , in_ =
                            if isTopLevel then
                                case List.reverse parents ++ [ self ] of
                                    [] ->
                                        CodeGen.Expression.value "viewPage model"

                                    first :: rest ->
                                        toNestedLayoutExpression first rest

                            else
                                toNestedLayoutExpression self parents
                        }
    in
    if List.isEmpty layouts then
        CodeGen.Expression.value "viewPage model"

    else
        CodeGen.Expression.letIn
            { let_ =
                [ { argument = CodeGen.Argument.new "route"
                  , annotation = Just (CodeGen.Annotation.type_ "Route ()")
                  , expression = CodeGen.Expression.value "Route.fromUrl () model.url"
                  }
                ]
            , in_ =
                CodeGen.Expression.caseExpression
                    { value = CodeGen.Argument.new "( toLayoutFromPage model, model.layout )"
                    , branches =
                        List.map toViewBranch layouts
                            ++ [ { name = "_"
                                 , arguments = []
                                 , expression = CodeGen.Expression.value "viewPage model"
                                 }
                               ]
                    }
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
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                toPageModelMapper
                    { page = page
                    , isAdvancedElmLandPage = isAdvancedElmLandPage
                    , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                    , function = "view"
                    , hasPageModelArg = True
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
                        [ CodeGen.Expression.multilineLambda
                            { arguments = [ CodeGen.Argument.new "user" ]
                            , expression = expression
                            }
                        , CodeGen.Expression.value "(Auth.onPageLoad model.shared (Route.fromUrl () model.url))"
                        ]
                    }

            else
                expression

        toBranchForStaticPage : PageFile -> CodeGen.Expression.Branch
        toBranchForStaticPage page =
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
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
                , [ { name = "Main.Pages.Model.Redirecting_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "View.none"
                    }
                  , { name = "Main.Pages.Model.Loading_"
                    , arguments = []
                    , expression =
                        CodeGen.Expression.pipeline
                            [ CodeGen.Expression.value "Auth.viewLoadingPage model.shared (Route.fromUrl () model.url)"
                            , CodeGen.Expression.value "View.map never"
                            ]
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
                "( Main.Pages.Msg.{{name}}, Main.Pages.Model.{{name}}{{args}} )"
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
                "( Main.Pages.Msg.{{name}} pageMsg, Main.Pages.Model.{{name}} {{args}} )"
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
                                    [ CodeGen.Expression.value ("Main.Pages.Msg." ++ PageFile.toVariantName page)
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
                "( Main.Pages.Msg.{{name}} pageMsg, Main.Pages.Model.{{name}} {{args}} )"
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
                                    [ CodeGen.Expression.value ("Main.Pages.Msg." ++ PageFile.toVariantName page)
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
        , branches = List.map toBranch pages ++ [ defaultCaseBranch ]
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

        toBranch :
            { layoutSendingMsg : LayoutFile
            , selfAndParents : List LayoutFile
            , maybeParent : Maybe LayoutFile
            , currentLayout : LayoutFile
            }
            -> CodeGen.Expression.Branch
        toBranch layoutOptions =
            let
                tupleMapExpression : CodeGen.Expression
                tupleMapExpression =
                    CodeGen.Expression.multilineFunction
                        { name = "Tuple.mapBoth"
                        , arguments =
                            [ layoutModelConstructor layoutOptions
                            , CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "Effect.map"
                                    , arguments =
                                        [ CodeGen.Expression.value
                                            ("Main.Layouts.Msg." ++ LayoutFile.toVariantName layoutOptions.layoutSendingMsg)
                                        ]
                                    }
                                , CodeGen.Expression.operator ">>"
                                , CodeGen.Expression.value "fromLayoutEffect model"
                                ]
                            , CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "Layout.update"
                                    , arguments =
                                        [ CodeGen.Expression.parens
                                            [ callLayoutFunction
                                                layoutOptions.maybeParent
                                                layoutOptions.layoutSendingMsg
                                            ]
                                        , CodeGen.Expression.value "layoutMsg"
                                        , CodeGen.Expression.value
                                            ("layoutModel.{{lastPartFieldName}}"
                                                |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layoutOptions.layoutSendingMsg)
                                            )
                                        ]
                                    }
                                ]
                            ]
                        }
            in
            { name =
                "( Just (Layouts.{{name}} settings), Just (Main.Layouts.Model.{{name}} layoutModel), Main.Layouts.Msg.{{layoutSendingMsg}} layoutMsg )"
                    |> String.replace "{{name}}" (LayoutFile.toVariantName layoutOptions.currentLayout)
                    |> String.replace "{{layoutSendingMsg}}" (LayoutFile.toVariantName layoutOptions.layoutSendingMsg)
            , arguments = []
            , expression =
                CodeGen.Expression.letIn
                    { let_ =
                        case layoutOptions.selfAndParents of
                            [] ->
                                []

                            self :: parentLayouts ->
                                if self == layoutOptions.layoutSendingMsg then
                                    []

                                else
                                    toParentsBetween layoutOptions
                                        |> List.map
                                            (\data ->
                                                toParentLayoutProps
                                                    { self = self
                                                    , child = data.child
                                                    , parent = data.parent
                                                    }
                                            )
                    , in_ = tupleMapExpression
                    }
            }

        toBranches : LayoutFile -> List CodeGen.Expression.Branch
        toBranches currentLayout =
            let
                selfAndParents =
                    LayoutFile.toListOfSelfAndParents currentLayout

                toBranchWithParent :
                    Maybe LayoutFile
                    -> LayoutFile
                    -> CodeGen.Expression.Branch
                toBranchWithParent maybeParent layout =
                    toBranch
                        { layoutSendingMsg = layout
                        , selfAndParents = selfAndParents
                        , maybeParent = maybeParent
                        , currentLayout = currentLayout
                        }
            in
            List.map2 toBranchWithParent
                (toListOfParents (List.reverse selfAndParents))
                selfAndParents
                |> List.reverse
    in
    CodeGen.Expression.letIn
        { let_ =
            [ { argument = CodeGen.Argument.new "route"
              , annotation = Just (CodeGen.Annotation.type_ "Route ()")
              , expression = CodeGen.Expression.value "Route.fromUrl () model.url"
              }
            ]
        , in_ =
            CodeGen.Expression.caseExpression
                { value = CodeGen.Argument.new "( toLayoutFromPage model, model.layout, msg )"
                , branches =
                    List.concatMap toBranches layouts
                        ++ [ defaultCaseBranch ]
                }
        }


{-| Get all layouts between the current layout and the layout sending a message. This function assumes that the current layout is
a child layout of the layout sending a message:

    toParentsBetween [ Sidebar.Header.Tabs, Sidebar.Header, Sidebar ]
        { layoutSendingMessage = Sidebar.Header
        , currentLayout = Sidebar.Header.Tabs
        }
        == [ { parent = Sidebar.Header, child = Sidebar.Header.Tabs }
           ]

    toParentsBetween [ Sidebar.Header.Tabs, Sidebar.Header, Sidebar ]
        { layoutSendingMessage = Sidebar
        , currentLayout = Sidebar.Header.Tabs
        }
        == [ { parent = Sidebar.Header, child = Sidebar.Header.Tabs }
           , { parent = Sidebar, child = Sidebar.Header }
           ]

    toParentsBetween [ Sidebar.Header, Sidebar ]
        { layoutSendingMessage = Sidebar
        , currentLayout = Sidebar.Header
        }
        == [ { parent = Sidebar, child = Sidebar.Header }
           ]

Used with `let` expressions to define the settings for a layout within an update function

-}
toParentsBetween :
    { options
        | selfAndParents : List LayoutFile
        , layoutSendingMsg : LayoutFile
        , currentLayout : LayoutFile
    }
    -> List { child : LayoutFile, parent : LayoutFile }
toParentsBetween options =
    let
        lengthCurrent : Int
        lengthCurrent =
            LayoutFile.toList options.currentLayout
                |> List.length

        lengthSendingMsg : Int
        lengthSendingMsg =
            LayoutFile.toList options.layoutSendingMsg
                |> List.length
    in
    List.map2 (\child parent -> { child = child, parent = parent })
        options.selfAndParents
        (options.selfAndParents
            |> List.drop 1
            |> List.take (lengthCurrent - lengthSendingMsg)
        )


{-| Example: Layouts.Sidebar.layout settings model.shared route
-}
callLayoutFunction : Maybe LayoutFile -> LayoutFile -> CodeGen.Expression
callLayoutFunction maybeParent layout =
    "{{moduleName}}.layout {{settings}} model.shared route"
        |> String.replace "{{moduleName}}" (LayoutFile.toModuleName layout)
        |> String.replace "{{settings}}"
            (case maybeParent of
                Just parent ->
                    toLayoutPropsVariableName parent

                Nothing ->
                    "settings"
            )
        |> CodeGen.Expression.value


toLayoutPropsVariableName : LayoutFile -> String
toLayoutPropsVariableName layout =
    LayoutFile.toLayoutVariableName layout ++ "Props"


toSubscriptionPageCaseExpression : List PageFile -> CodeGen.Expression.Expression
toSubscriptionPageCaseExpression pages =
    let
        toBranchForStaticPage : PageFile -> CodeGen.Expression.Branch
        toBranchForStaticPage page =
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression = CodeGen.Expression.value "Sub.none"
            }

        toBranchForElmLandPage : Bool -> PageFile -> CodeGen.Expression.Branch
        toBranchForElmLandPage isAdvancedElmLandPage page =
            { name = "Main.Pages.Model." ++ PageFile.toVariantName page
            , arguments = toPageModelArgs page
            , expression =
                toPageModelMapper
                    { isAdvancedElmLandPage = isAdvancedElmLandPage
                    , isAuthProtectedPage = PageFile.isAuthProtectedPage page
                    , page = page
                    , function = "subscriptions"
                    , hasPageModelArg = True
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
                        [ CodeGen.Expression.multilineLambda
                            { arguments = [ CodeGen.Argument.new "user" ]
                            , expression = expression
                            }
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
                , [ { name = "Main.Pages.Model.Redirecting_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  , { name = "Main.Pages.Model.Loading_"
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
            { name =
                "( Just (Layouts.{{name}} settings), Just (Main.Layouts.Model.{{name}} layoutModel) )"
                    |> String.replace "{{name}}" (LayoutFile.toVariantName layout)
            , arguments =
                []
            , expression =
                toBranchExpression layout
            }

        toBranchExpression : LayoutFile -> CodeGen.Expression
        toBranchExpression layout =
            case LayoutFile.toListOfSelfAndParents layout of
                [] ->
                    CodeGen.Expression.value "Sub.none"

                self :: [] ->
                    toSubscriptionExpression Nothing layout

                self :: parentLayouts ->
                    let
                        selfAndParentLayouts : List LayoutFile
                        selfAndParentLayouts =
                            self :: parentLayouts
                    in
                    CodeGen.Expression.letIn
                        { let_ =
                            List.map2
                                (\child parent ->
                                    toParentLayoutProps
                                        { self = self
                                        , child = child
                                        , parent = parent
                                        }
                                )
                                selfAndParentLayouts
                                parentLayouts
                        , in_ =
                            CodeGen.Expression.multilineFunction
                                { name = "Sub.batch"
                                , arguments =
                                    [ CodeGen.Expression.multilineList
                                        (List.map2 toSubscriptionExpression
                                            (toListOfParents (List.reverse selfAndParentLayouts))
                                            selfAndParentLayouts
                                            |> List.reverse
                                        )
                                    ]
                                }
                        }

        toSubscriptionExpression : Maybe LayoutFile -> LayoutFile -> CodeGen.Expression
        toSubscriptionExpression maybeParent layout =
            CodeGen.Expression.pipeline
                [ CodeGen.Expression.function
                    { name = "Layout.subscriptions"
                    , arguments =
                        [ CodeGen.Expression.parens
                            [ callLayoutFunction maybeParent layout
                            ]
                        , CodeGen.Expression.value
                            ("layoutModel.{{lastPartFieldName}}"
                                |> String.replace "{{lastPartFieldName}}"
                                    (LayoutFile.toLastPartFieldName layout)
                            )
                        ]
                    }
                , CodeGen.Expression.value ("Sub.map Main.Layouts.Msg." ++ LayoutFile.toVariantName layout)
                , CodeGen.Expression.value "Sub.map LayoutSent"
                ]
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "( maybeLayout, model.layout )"
        , branches =
            List.concat
                [ List.map toBranch layouts
                , [ { name = "_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  ]
                ]
        }


toParentLayoutProps :
    { self : LayoutFile
    , child : LayoutFile
    , parent : LayoutFile
    }
    -> CodeGen.Expression.LetDeclaration
toParentLayoutProps { self, child, parent } =
    { argument =
        toLayoutPropsVariableName parent
            |> CodeGen.Argument.new
    , annotation = Nothing
    , expression =
        CodeGen.Expression.pipeline
            [ "{{moduleName}}.layout {{settings}} model.shared route"
                |> String.replace "{{moduleName}}" (LayoutFile.toModuleName child)
                |> String.replace "{{settings}}"
                    (if self == child then
                        "settings"

                     else
                        toLayoutPropsVariableName child
                    )
                |> CodeGen.Expression.value
            , CodeGen.Expression.value "Layout.parentProps"
            ]
    }


{-| Note: This function assumes items come in from parent to child

✅ [ Sidebar, Sidebar.Header, Sidebar.Header.Tabs ]

❌ [ Sidebar.Header.Tabs, Sidebar.Header, Sidebar ]

    toListOfParents [ Sidebar, Sidebar.Header, Sidebar.Header.Tabs ]
        == [ Nothing
           , Just Sidebar.Header
           , Just Sidebar
           ]

    toListOfParents [ Sidebar ]
        == [ Nothing ]

    toListOfParents [ Sidebar, Sidebar.Header ]
        == [ Nothing, Just Sidebar ]

-}
toListOfParents : List LayoutFile -> List (Maybe LayoutFile)
toListOfParents layoutFiles =
    Nothing
        :: (layoutFiles
                |> dropLastItem
                |> List.reverse
                |> List.map Just
           )


dropLastItem : List a -> List a
dropLastItem items =
    List.reverse items
        |> List.drop 1
        |> List.reverse


toInitLayoutCaseExpression : List LayoutFile -> CodeGen.Expression.Expression
toInitLayoutCaseExpression layouts =
    let
        toBranchForLayout : LayoutFile -> List CodeGen.Expression.Branch
        toBranchForLayout layoutFile =
            LayoutFile.toInitBranches
                { target = layoutFile
                , layouts = layouts
                }
    in
    CodeGen.Expression.caseExpression
        { value = CodeGen.Argument.new "( layout, model.layout )"
        , branches = List.concatMap toBranchForLayout layouts
        }


toInitPageCaseExpression : List LayoutFile -> List PageFile -> CodeGen.Expression.Expression
toInitPageCaseExpression layouts pages =
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
                                        [ CodeGen.Expression.value ("Main.Pages.Msg." ++ PageFile.toVariantName page)
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
                                        [ CodeGen.Expression.value ("Main.Pages.Msg." ++ PageFile.toVariantName page)
                                        ]
                                    }
                                , CodeGen.Expression.operator ">>"
                                , CodeGen.Expression.value "fromPageEffect model"
                                ]
                            , CodeGen.Expression.tuple
                                [ CodeGen.Expression.value "pageModel"
                                , CodeGen.Expression.value "pageEffect"
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
                    , { argument = CodeGen.Argument.new "( pageModel, pageEffect )"
                      , annotation = Nothing
                      , expression =
                            CodeGen.Expression.function
                                { name = "Page.init"
                                , arguments =
                                    [ CodeGen.Expression.value "page"
                                    , CodeGen.Expression.value "()"
                                    ]
                                }
                      }
                    ]
                , in_ =
                    CodeGen.Expression.multilineRecord
                        [ ( "page", pageExpression )
                        , ( "layout"
                          , if List.isEmpty layouts then
                                CodeGen.Expression.value "Nothing"

                            else
                                CodeGen.Expression.pipeline
                                    [ CodeGen.Expression.value "Page.layout pageModel page"
                                    , CodeGen.Expression.value
                                        ("Maybe.map (Layouts.map ({{msgVariant}} >> PageSent))"
                                            |> String.replace "{{msgVariant}}" ("Main.Pages.Msg." ++ PageFile.toVariantName page)
                                        )
                                    , CodeGen.Expression.value "Maybe.map (initLayout model)"
                                    ]
                          )
                        ]
                }

        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            let
                branchExpression : CodeGen.Expression
                branchExpression =
                    conditionallyWrapInRunWhenAuthenticatedWithLayout page
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
            List.map toBranch pages
        }


conditionallyWrapInRunWhenAuthenticated : PageFile -> CodeGen.Expression -> CodeGen.Expression
conditionallyWrapInRunWhenAuthenticated page expression =
    if PageFile.isAuthProtectedPage page then
        CodeGen.Expression.multilineFunction
            { name = "runWhenAuthenticated"
            , arguments =
                [ CodeGen.Expression.value "model"
                , CodeGen.Expression.multilineLambda
                    { arguments = [ CodeGen.Argument.new "user" ]
                    , expression = expression
                    }
                ]
            }

    else
        expression


conditionallyWrapInRunWhenAuthenticatedWithLayout : PageFile -> CodeGen.Expression -> CodeGen.Expression
conditionallyWrapInRunWhenAuthenticatedWithLayout page expression =
    if PageFile.isAuthProtectedPage page then
        CodeGen.Expression.multilineFunction
            { name = "runWhenAuthenticatedWithLayout"
            , arguments =
                [ CodeGen.Expression.value "model"
                , CodeGen.Expression.multilineLambda
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
                { name = "Main.Pages.Model." ++ PageFile.toVariantName page
                , arguments = [ CodeGen.Expression.value "params" ]
                }
            ]

    else
        CodeGen.Expression.value ("Main.Pages.Model." ++ PageFile.toVariantName page)


{-| Example:

    \newModel -> Just (LayoutModelSidebar { layout | model = newModel })

-}
layoutModelConstructor : { options | layoutSendingMsg : LayoutFile, currentLayout : LayoutFile } -> CodeGen.Expression
layoutModelConstructor layoutOptions =
    CodeGen.Expression.lambda
        { arguments = [ CodeGen.Argument.new "newModel" ]
        , expression =
            "Just (Main.Layouts.Model.{{name}} { layoutModel | {{lastPartFieldName}} = newModel })"
                |> String.replace "{{name}}" (LayoutFile.toVariantName layoutOptions.currentLayout)
                |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layoutOptions.layoutSendingMsg)
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
    , hasPageModelArg : Bool
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
                , if options.hasPageModelArg then
                    CodeGen.Expression.value "pageModel"

                  else
                    CodeGen.Expression.value ""
                ]
            }
        , CodeGen.Expression.function
            { name = options.mapper
            , arguments = [ CodeGen.Expression.value ("Main.Pages.Msg." ++ routeVariantName) ]
            }
        , CodeGen.Expression.function
            { name = options.mapper
            , arguments = [ CodeGen.Expression.value "PageSent" ]
            }
        ]


routeElmModule : Data -> CodeGen.Module
routeElmModule data =
    let
        routeAnnotation =
            CodeGen.Annotation.genericType "Route"
                [ CodeGen.Annotation.type_ "params" ]

        queryAnnotation =
            CodeGen.Annotation.genericType "Dict"
                [ CodeGen.Annotation.string
                , CodeGen.Annotation.string
                ]

        hashAnnotation =
            CodeGen.Annotation.genericType "Maybe"
                [ CodeGen.Annotation.string ]
    in
    CodeGen.Module.new
        { name = [ "Route" ]
        , exposing_ = [ "Route", "fromUrl", "href", "toString" ]
        , imports =
            List.concat
                [ [ CodeGen.Import.new [ "Dict" ]
                        |> CodeGen.Import.withExposing [ "Dict" ]
                  , CodeGen.Import.new [ "Html" ]
                  , CodeGen.Import.new [ "Html.Attributes" ]
                  , CodeGen.Import.new [ "Route.Path" ]
                  , CodeGen.Import.new [ "Route.Query" ]
                  , CodeGen.Import.new [ "Url" ]
                        |> CodeGen.Import.withExposing [ "Url" ]
                  ]
                , if data.options.useHashRouting then
                    [ CodeGen.Import.new [ "HashRouting" ] ]

                  else
                    []
                ]
        , declarations =
            [ CodeGen.Declaration.typeAlias
                { name = "Route params"
                , annotation =
                    CodeGen.Annotation.multilineRecord
                        [ ( "path", CodeGen.Annotation.type_ "Route.Path.Path" )
                        , ( "params", CodeGen.Annotation.type_ "params" )
                        , ( "query", queryAnnotation )
                        , ( "hash", hashAnnotation )
                        , ( "url", CodeGen.Annotation.type_ "Url" )
                        ]
                }
            , CodeGen.Declaration.function
                { name = "fromUrl"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "params"
                        , CodeGen.Annotation.type_ "Url"
                        , routeAnnotation
                        ]
                , arguments =
                    [ CodeGen.Argument.new "params"
                    , CodeGen.Argument.new "url"
                    ]
                , expression =
                    CodeGen.Expression.multilineRecord
                        [ ( "path"
                          , CodeGen.Expression.function
                                { name = "Route.Path.fromUrl"
                                , arguments = [ CodeGen.Expression.value "url" ]
                                }
                          )
                        , ( "params", CodeGen.Expression.value "params" )
                        , ( "query"
                          , CodeGen.Expression.function
                                { name = "Route.Query.fromUrl"
                                , arguments = [ CodeGen.Expression.value "url" ]
                                }
                          )
                        , ( "hash"
                          , if data.options.useHashRouting then
                                CodeGen.Expression.pipeline
                                    [ CodeGen.Expression.function
                                        { name = "HashRouting.transformToHashUrl"
                                        , arguments = [ CodeGen.Expression.value "url" ]
                                        }
                                    , CodeGen.Expression.function
                                        { name = "Maybe.andThen"
                                        , arguments = [ CodeGen.Expression.value ".fragment" ]
                                        }
                                    ]

                            else
                                CodeGen.Expression.value "url.fragment"
                          )
                        , ( "url", CodeGen.Expression.value "url" )
                        ]
                }
            , CodeGen.Declaration.function
                { name = "href"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.record
                            [ ( "path", CodeGen.Annotation.type_ "Route.Path.Path" )
                            , ( "query", queryAnnotation )
                            , ( "hash", hashAnnotation )
                            ]
                        , CodeGen.Annotation.genericType "Html.Attribute"
                            [ CodeGen.Annotation.type_ "msg" ]
                        ]
                , arguments = [ CodeGen.Argument.new "route" ]
                , expression =
                    CodeGen.Expression.function
                        { name = "Html.Attributes.href"
                        , arguments =
                            [ CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = "toString"
                                    , arguments = [ CodeGen.Expression.value "route" ]
                                    }
                                ]
                            ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "toString"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.extensibleRecord "route"
                            [ ( "path", CodeGen.Annotation.type_ "Route.Path.Path" )
                            , ( "query", queryAnnotation )
                            , ( "hash", hashAnnotation )
                            ]
                        , CodeGen.Annotation.string
                        ]
                , arguments = [ CodeGen.Argument.new "route" ]
                , expression =
                    CodeGen.Expression.multilineFunction
                        { name = "String.join"
                        , arguments =
                            [ CodeGen.Expression.string ""
                            , CodeGen.Expression.multilineList
                                [ CodeGen.Expression.function
                                    { name = "Route.Path.toString"
                                    , arguments = [ CodeGen.Expression.value "route.path" ]
                                    }
                                , CodeGen.Expression.function
                                    { name = "Route.Query.toString"
                                    , arguments = [ CodeGen.Expression.value "route.query" ]
                                    }
                                , CodeGen.Expression.pipeline
                                    [ CodeGen.Expression.value "route.hash"
                                    , CodeGen.Expression.function
                                        { name = "Maybe.map"
                                        , arguments =
                                            [ CodeGen.Expression.parens
                                                [ CodeGen.Expression.function
                                                    { name = "String.append"
                                                    , arguments = [ CodeGen.Expression.string "#" ]
                                                    }
                                                ]
                                            ]
                                        }
                                    , CodeGen.Expression.function
                                        { name = "Maybe.withDefault"
                                        , arguments = [ CodeGen.Expression.string "" ]
                                        }
                                    ]
                                ]
                            ]
                        }
                }
            ]
        }


routePathElmModule : Data -> CodeGen.Module
routePathElmModule data =
    CodeGen.Module.new
        { name = [ "Route", "Path" ]
        , exposing_ = [ "Path(..)", "fromString", "fromUrl", "href", "toString" ]
        , imports =
            List.concat
                [ [ CodeGen.Import.new [ "Html" ]
                  , CodeGen.Import.new [ "Html.Attributes" ]
                  , CodeGen.Import.new [ "Url" ]
                        |> CodeGen.Import.withExposing [ "Url" ]
                  , CodeGen.Import.new [ "Url.Parser" ]
                        |> CodeGen.Import.withExposing [ "(</>)" ]
                  ]
                , if data.options.useHashRouting then
                    [ CodeGen.Import.new [ "HashRouting" ] ]

                  else
                    []
                ]
        , declarations =
            [ CodeGen.Declaration.customType
                { name = "Path"
                , variants =
                    data.pages
                        |> List.map PageFile.toRouteVariant
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
                    if data.options.useHashRouting then
                        CodeGen.Expression.pipeline
                            [ CodeGen.Expression.function
                                { name = "HashRouting.transformToHashUrl"
                                , arguments = [ CodeGen.Expression.value "url" ]
                                }
                            , CodeGen.Expression.value "Maybe.map .path"
                            , CodeGen.Expression.value "Maybe.andThen fromString"
                            , CodeGen.Expression.function
                                { name = "Maybe.withDefault"
                                , arguments =
                                    [ CodeGen.Expression.value "NotFound_"
                                    ]
                                }
                            ]

                    else
                        CodeGen.Expression.pipeline
                            [ CodeGen.Expression.function
                                { name = "fromString"
                                , arguments = [ CodeGen.Expression.value "url.path" ]
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
                { name = "fromString"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "String"
                        , CodeGen.Annotation.type_ "Maybe Path"
                        ]
                , arguments = [ CodeGen.Argument.new "urlPath" ]
                , expression = routePathFromStringExpression data
                }
            , CodeGen.Declaration.function
                { name = "href"
                , annotation = CodeGen.Annotation.function [ CodeGen.Annotation.type_ "Path", CodeGen.Annotation.type_ "Html.Attribute msg" ]
                , arguments = [ CodeGen.Argument.new "path" ]
                , expression = CodeGen.Expression.value "Html.Attributes.href (toString path)"
                }
            , CodeGen.Declaration.function
                { name = "toString"
                , annotation = CodeGen.Annotation.function [ CodeGen.Annotation.type_ "Path", CodeGen.Annotation.string ]
                , arguments = [ CodeGen.Argument.new "path" ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "pieces"
                              , annotation = Just (CodeGen.Annotation.type_ "List String")
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
                                    , arguments =
                                        [ if data.options.useHashRouting then
                                            CodeGen.Expression.string "#/"

                                          else
                                            CodeGen.Expression.string "/"
                                        ]
                                    }
                                ]
                        }
                }
            ]
        }


routePathFromStringExpression : { data | pages : List PageFile } -> CodeGen.Expression
routePathFromStringExpression { pages } =
    let
        toBranch : PageFile -> CodeGen.Expression.Branch
        toBranch page =
            PageFile.toRouteFromStringBranch page

        nothingBranch : CodeGen.Expression.Branch
        nothingBranch =
            { name = "_"
            , arguments = []
            , expression = CodeGen.Expression.value "Nothing"
            }
    in
    CodeGen.Expression.letIn
        { let_ =
            [ { argument = CodeGen.Argument.new "urlPathSegments"
              , annotation = Just (CodeGen.Annotation.type_ "List String")
              , expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.value "urlPath"
                        , CodeGen.Expression.function { name = "String.split", arguments = [ CodeGen.Expression.string "/" ] }
                        , CodeGen.Expression.value "List.filter (String.trim >> String.isEmpty >> Basics.not)"
                        ]
              }
            ]
        , in_ =
            CodeGen.Expression.caseExpression
                { value = CodeGen.Argument.new "urlPathSegments"
                , branches =
                    if List.any PageFile.isTopLevelCatchAllPage pages then
                        pages
                            |> List.filter (\page -> not (PageFile.isNotFoundPage page))
                            |> List.map toBranch

                    else
                        List.map toBranch pages ++ [ nothingBranch ]
                }
        }


toRoutePathToStringBranches : List PageFile -> List CodeGen.Expression.Branch
toRoutePathToStringBranches files =
    List.map toRoutePathToStringBranch files


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
                            if piece == "ALL_" then
                                CodeGen.Expression.value "String.join \"/\" params.all_"

                            else if piece == "NotFound_" then
                                CodeGen.Expression.string "404"

                            else if String.endsWith "_" piece then
                                CodeGen.Expression.value
                                    ("params."
                                        ++ (piece |> String.dropRight 1 |> Extras.String.fromPascalCaseToCamelCase)
                                    )

                            else
                                CodeGen.Expression.string (Extras.String.fromPascalCaseToKebabCase piece)
                        )
                )
    }


routeQueryElmModule : Data -> CodeGen.Module
routeQueryElmModule data =
    CodeGen.Module.new
        { name = [ "Route", "Query" ]
        , exposing_ = [ "fromUrl", "toString" ]
        , imports =
            List.concat
                [ [ CodeGen.Import.new [ "Dict" ]
                        |> CodeGen.Import.withExposing [ "Dict" ]
                  , CodeGen.Import.new [ "Url" ]
                        |> CodeGen.Import.withExposing [ "Url" ]
                  , CodeGen.Import.new [ "Url.Parser" ]
                        |> CodeGen.Import.withExposing [ "query" ]
                  , CodeGen.Import.new [ "Url.Builder" ]
                        |> CodeGen.Import.withExposing [ "QueryParameter" ]
                  ]
                , if data.options.useHashRouting then
                    [ CodeGen.Import.new [ "HashRouting" ] ]

                  else
                    []
                ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "fromUrl"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Url"
                        , CodeGen.Annotation.genericType "Dict"
                            [ CodeGen.Annotation.string
                            , CodeGen.Annotation.string
                            ]
                        ]
                , arguments =
                    [ CodeGen.Argument.new "url"
                    ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value =
                            if data.options.useHashRouting then
                                CodeGen.Argument.new "Maybe.andThen .query (HashRouting.transformToHashUrl url)"

                            else
                                CodeGen.Argument.new "url.query"
                        , branches =
                            [ { name = "Nothing"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.value "Dict.empty"
                              }
                            , { name = "Just"
                              , arguments = [ CodeGen.Argument.new "query" ]
                              , expression =
                                    CodeGen.Expression.ifElse
                                        { condition =
                                            CodeGen.Expression.function
                                                { name = "String.isEmpty"
                                                , arguments = [ CodeGen.Expression.value "query" ]
                                                }
                                        , ifBranch =
                                            CodeGen.Expression.value "Dict.empty"
                                        , elseBranch =
                                            CodeGen.Expression.pipeline
                                                [ CodeGen.Expression.value "query"
                                                , CodeGen.Expression.function
                                                    { name = "String.split"
                                                    , arguments = [ CodeGen.Expression.string "&" ]
                                                    }
                                                , CodeGen.Expression.function
                                                    { name = "List.filterMap"
                                                    , arguments =
                                                        [ CodeGen.Expression.parens
                                                            [ CodeGen.Expression.function
                                                                { name = "String.split"
                                                                , arguments = [ CodeGen.Expression.string "=" ]
                                                                }
                                                            , CodeGen.Expression.operator ">>"
                                                            , CodeGen.Expression.value "queryPiecesToTuple"
                                                            ]
                                                        ]
                                                    }
                                                , CodeGen.Expression.value "Dict.fromList"
                                                ]
                                        }
                              }
                            ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "queryPiecesToTuple"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.genericType "List"
                            [ CodeGen.Annotation.string ]
                        , CodeGen.Annotation.genericType "Maybe"
                            [ CodeGen.Annotation.type_ "(String, String)" ]
                        ]
                , arguments = [ CodeGen.Argument.new "pieces" ]
                , expression =
                    CodeGen.Expression.caseExpression
                        { value = CodeGen.Argument.new "pieces"
                        , branches =
                            [ { name = "[]"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.value "Nothing"
                              }
                            , { name = "key :: []"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Just"
                                        , arguments =
                                            [ CodeGen.Expression.tuple
                                                [ CodeGen.Expression.function
                                                    { name = "decodeQueryToken"
                                                    , arguments = [ CodeGen.Expression.value "key" ]
                                                    }
                                                , CodeGen.Expression.string ""
                                                ]
                                            ]
                                        }
                              }
                            , { name = "key :: value :: _"
                              , arguments = []
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Just"
                                        , arguments =
                                            [ CodeGen.Expression.tuple
                                                [ CodeGen.Expression.function
                                                    { name = "decodeQueryToken"
                                                    , arguments = [ CodeGen.Expression.value "key" ]
                                                    }
                                                , CodeGen.Expression.function
                                                    { name = "decodeQueryToken"
                                                    , arguments = [ CodeGen.Expression.value "value" ]
                                                    }
                                                ]
                                            ]
                                        }
                              }
                            ]
                        }
                }
            , CodeGen.Declaration.function
                { name = "decodeQueryToken"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.string, CodeGen.Annotation.string ]
                , arguments = [ CodeGen.Argument.new "val" ]
                , expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.function
                            { name = "Url.percentDecode"
                            , arguments = [ CodeGen.Expression.value "val" ]
                            }
                        , CodeGen.Expression.function
                            { name = "Maybe.withDefault"
                            , arguments = [ CodeGen.Expression.value "val" ]
                            }
                        ]
                }
            , CodeGen.Declaration.function
                { name = "toString"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.genericType "Dict"
                            [ CodeGen.Annotation.string
                            , CodeGen.Annotation.string
                            ]
                        , CodeGen.Annotation.string
                        ]
                , arguments = [ CodeGen.Argument.new "queryParameterList" ]
                , expression =
                    CodeGen.Expression.pipeline
                        [ CodeGen.Expression.value "queryParameterList"
                        , CodeGen.Expression.function { name = "Dict.toList", arguments = [] }
                        , CodeGen.Expression.function
                            { name = "List.map"
                            , arguments = [ CodeGen.Expression.value "tupleToQueryPiece" ]
                            }
                        , CodeGen.Expression.function
                            { name = "Url.Builder.toQuery"
                            , arguments = []
                            }
                        ]
                }
            , CodeGen.Declaration.function
                { name = "tupleToQueryPiece"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "(String, String)"
                        , CodeGen.Annotation.type_ "QueryParameter"
                        ]
                , arguments = [ CodeGen.Argument.new "( key, value )" ]
                , expression =
                    CodeGen.Expression.function
                        { name = "Url.Builder.string"
                        , arguments = [ CodeGen.Expression.value "key", CodeGen.Expression.value "value" ]
                        }
                }
            ]
        }


hashRoutingElmModule : CodeGen.Module
hashRoutingElmModule =
    CodeGen.Module.new
        { name = [ "HashRouting" ]
        , exposing_ = [ "transformToHashUrl" ]
        , imports =
            [ CodeGen.Import.new [ "Url" ]
                |> CodeGen.Import.withExposing [ "Url" ]
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "transformToHashUrl"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.type_ "Url"
                        , CodeGen.Annotation.genericType "Maybe"
                            [ CodeGen.Annotation.type_ "Url" ]
                        ]
                , arguments = [ CodeGen.Argument.new "url" ]
                , expression =
                    CodeGen.Expression.letIn
                        { let_ =
                            [ { argument = CodeGen.Argument.new "protocol"
                              , annotation = Just CodeGen.Annotation.string
                              , expression =
                                    CodeGen.Expression.caseExpression
                                        { value = CodeGen.Argument.new "url.protocol"
                                        , branches =
                                            [ { name = "Url.Http"
                                              , arguments = []
                                              , expression =
                                                    CodeGen.Expression.string "http://"
                                              }
                                            , { name = "Url.Https"
                                              , arguments = []
                                              , expression =
                                                    CodeGen.Expression.string "https://"
                                              }
                                            ]
                                        }
                              }
                            , { argument = CodeGen.Argument.new "host"
                              , annotation = Just CodeGen.Annotation.string
                              , expression = CodeGen.Expression.value "url.host"
                              }
                            , { argument = CodeGen.Argument.new "port_"
                              , annotation = Just CodeGen.Annotation.string
                              , expression =
                                    CodeGen.Expression.caseExpression
                                        { value = CodeGen.Argument.new "url.port_"
                                        , branches =
                                            [ { name = "Just"
                                              , arguments = [ CodeGen.Argument.new "int" ]
                                              , expression =
                                                    CodeGen.Expression.parens
                                                        [ CodeGen.Expression.string ":"
                                                        , CodeGen.Expression.operator "++"
                                                        , CodeGen.Expression.function
                                                            { name = "String.fromInt"
                                                            , arguments = [ CodeGen.Expression.value "int" ]
                                                            }
                                                        ]
                                              }
                                            , { name = "Nothing"
                                              , arguments = []
                                              , expression = CodeGen.Expression.string ""
                                              }
                                            ]
                                        }
                              }
                            , { argument = CodeGen.Argument.new "fragment"
                              , annotation = Just CodeGen.Annotation.string
                              , expression =
                                    CodeGen.Expression.function
                                        { name = "Maybe.withDefault"
                                        , arguments =
                                            [ CodeGen.Expression.string ""
                                            , CodeGen.Expression.value "url.fragment"
                                            ]
                                        }
                              }
                            ]
                        , in_ =
                            CodeGen.Expression.pipeline
                                [ CodeGen.Expression.list
                                    [ CodeGen.Expression.value "protocol"
                                    , CodeGen.Expression.value "host"
                                    , CodeGen.Expression.value "port_"
                                    , CodeGen.Expression.value "fragment"
                                    ]
                                , CodeGen.Expression.function
                                    { name = "String.concat", arguments = [] }
                                , CodeGen.Expression.function
                                    { name = "Url.fromString", arguments = [] }
                                ]
                        }
                }
            ]
        }


{-|

    module Layouts exposing (Layout(..))

    import Layouts.Default
    import Layouts.Sidebar

    type Layout
        = Default Layouts.Default.Props
        | Sidebar Layouts.Sidebar.Props

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
        , exposing_ = [ ".." ]
        , imports = List.map toLayoutImport data.layouts
        , declarations =
            [ LayoutFile.toLayoutTypeDeclaration data.layouts
            , LayoutFile.toMapFunction data.layouts
            ]
        }


{-| This represents the data we expect to receive from JavaScript
-}
type alias Data =
    { pages : List PageFile
    , layouts : List LayoutFile
    , options : RoutingOptions
    }


type alias RoutingOptions =
    { useHashRouting : Bool
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map3 Data
        (Json.Decode.field "pages"
            (Json.Decode.list PageFile.decoder
                |> Json.Decode.map PageFile.sortBySpecificity
            )
        )
        (Json.Decode.field "layouts" (Json.Decode.list LayoutFile.decoder)
            |> Json.Decode.map (List.sortWith LayoutFile.sorter)
        )
        (Json.Decode.field "router" routingOptionsDecoder)


routingOptionsDecoder : Json.Decode.Decoder RoutingOptions
routingOptionsDecoder =
    Json.Decode.oneOf
        [ Json.Decode.map RoutingOptions
            (Json.Decode.field "useHashRouting" Json.Decode.bool)
        , Json.Decode.succeed
            { useHashRouting = False
            }
        ]


ignoreNotFoundPage : List PageFile -> List PageFile
ignoreNotFoundPage pageFiles =
    pageFiles
        |> List.filter (PageFile.isNotFoundPage >> not)
