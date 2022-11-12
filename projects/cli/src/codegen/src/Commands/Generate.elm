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
            , mainPagesModelModule data
            , mainPagesMsgModule data
            , mainLayoutsModelModule data
            , mainLayoutsMsgModule data
            , routePathElmModule data
            , layoutsElmModule data
            ]

        Err _ ->
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
                            , CodeGen.Annotation.type_ "Layouts.Layout"
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
                              , annotation = Just (CodeGen.Annotation.type_ "Maybe Layouts.Layout")
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
                , toMainMsg = "PageSent"
                }
            , fromEffectDeclaration
                { name = "fromLayoutEffect"
                , msgType = "Main.Layouts.Msg.Msg"
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


{-| This is a thing:

        toLayoutFromPage : Model -> Maybe Layouts.Layout
        toLayoutFromPage model =
            case model.page of
                PageModelAuthors pageModel ->
                    let
                        page =
                            Pages.Authors.page model.shared (Route.fromUrl () model.url)
                    in
                    Page.layout page

                PageModelBlogPosts pageModel ->
                    let
                        page =
                            Pages.BlogPosts.page model.shared (Route.fromUrl () model.url)
                    in
                    Page.layout page

                PageModelHome_ pageModel ->
                    let
                        page =
                            Pages.Home_.page model.shared (Route.fromUrl () model.url)
                    in
                    Page.layout page

                PageModelNotFound_ ->
                    Nothing

                Redirecting ->
                    Nothing

                Loading _ ->
                    Nothing

-}
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
                            , CodeGen.Expression.value "Maybe.andThen Page.layout"
                            ]

                    else
                        CodeGen.Expression.pipeline
                            [ if PageFile.hasDynamicParameters page then
                                CodeGen.Expression.value "Route.fromUrl params model.url"

                              else
                                CodeGen.Expression.value "Route.fromUrl () model.url"
                            , CodeGen.Expression.value ("{{moduleName}}.page model.shared" |> String.replace "{{moduleName}}" (PageFile.toModuleName page))
                            , CodeGen.Expression.value "Page.layout"
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
        , annotation = CodeGen.Annotation.type_ "Model -> Maybe Layouts.Layout"
        , arguments = [ CodeGen.Argument.new "model" ]
        , expression =
            CodeGen.Expression.caseExpression
                { value = CodeGen.Argument.new "model.page"
                , branches =
                    List.map toBranch pages
                        ++ List.map toNothingBranch [ "NotFound_", "Redirecting_", "Loading_ _" ]
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
    List.concat
        [ List.map toCustomType pages
        , [ ( "NotFound_", [] ) ]
        ]


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
                              , expression = CodeGen.Expression.value "toRecord user"
                              }
                            , { name = "Auth.Action.ShowLoadingPage"
                              , arguments = [ CodeGen.Argument.new "loadingView" ]
                              , expression =
                                    wrapInPageLayout
                                        (CodeGen.Expression.multilineTuple
                                            [ CodeGen.Expression.value "Main.Pages.Model.Loading_ loadingView"
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
            , expression = toViewBranchExpression (List.reverse selfAndParentLayouts)
            }

        toViewBranchExpression : List LayoutFile -> CodeGen.Expression
        toViewBranchExpression layoutList =
            case layoutList of
                [] ->
                    CodeGen.Expression.value "viewPage model"

                layout :: rest ->
                    CodeGen.Expression.multilineFunction
                        { name = "Layout.view"
                        , arguments =
                            [ CodeGen.Expression.parens
                                [ CodeGen.Expression.function
                                    { name = LayoutFile.toModuleName layout ++ ".layout"
                                    , arguments =
                                        [ CodeGen.Expression.value
                                            ("settings.{{lastPartFieldName}} model.shared route"
                                                |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layout)
                                            )
                                        ]
                                    }
                                ]
                            , CodeGen.Expression.multilineRecord
                                [ ( "model"
                                  , CodeGen.Expression.value
                                        ("layoutModel.{{lastPartFieldName}}"
                                            |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layout)
                                        )
                                  )
                                , ( "toMainMsg"
                                  , "Main.Layouts.Msg.{{name}} >> LayoutSent"
                                        |> String.replace "{{name}}" (LayoutFile.toVariantName layout)
                                        |> CodeGen.Expression.value
                                  )
                                , ( "content", toViewBranchExpression rest )
                                ]
                            ]
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
                , [ { name = "Main.Pages.Model.NotFound_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Pages.NotFound_.page"
                    }
                  , { name = "Main.Pages.Model.Redirecting_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "View.none"
                    }
                  , { name = "Main.Pages.Model.Loading_ loadingView"
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
        , branches =
            List.concat
                [ List.map toBranch pages
                , [ { name = "( Main.Pages.Msg.NotFound_, Main.Pages.Model.NotFound_ )"
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

        toBranch : { sendingMessage : LayoutFile, currentLayout : LayoutFile } -> CodeGen.Expression.Branch
        toBranch layoutOptions =
            { name =
                "( Just (Layouts.{{name}} settings), Just (Main.Layouts.Model.{{name}} layoutModel), Main.Layouts.Msg.{{sendingMsgName}} layoutMsg )"
                    |> String.replace "{{name}}" (LayoutFile.toVariantName layoutOptions.currentLayout)
                    |> String.replace "{{sendingMsgName}}" (LayoutFile.toVariantName layoutOptions.sendingMessage)
            , arguments = []
            , expression =
                CodeGen.Expression.multilineFunction
                    { name = "Tuple.mapBoth"
                    , arguments =
                        [ layoutModelConstructor layoutOptions
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Effect.map"
                                , arguments =
                                    [ CodeGen.Expression.value ("Main.Layouts.Msg." ++ LayoutFile.toVariantName layoutOptions.sendingMessage)
                                    ]
                                }
                            , CodeGen.Expression.operator ">>"
                            , CodeGen.Expression.value "fromLayoutEffect model"
                            ]
                        , CodeGen.Expression.parens
                            [ CodeGen.Expression.function
                                { name = "Layout.update"
                                , arguments =
                                    [ CodeGen.Expression.parens [ callLayoutFunction layoutOptions.sendingMessage ]
                                    , CodeGen.Expression.value "layoutMsg"
                                    , CodeGen.Expression.value
                                        ("layoutModel.{{lastPartFieldName}}"
                                            |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layoutOptions.sendingMessage)
                                        )
                                    ]
                                }
                            ]
                        ]
                    }
            }

        toBranches : LayoutFile -> List CodeGen.Expression.Branch
        toBranches currentLayout =
            LayoutFile.toListOfSelfAndParents currentLayout
                |> List.reverse
                |> List.map (\layout -> toBranch { sendingMessage = layout, currentLayout = currentLayout })
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


{-| Example: (Layouts.Sidebar.layout settings.sidebar model.shared route
-}
callLayoutFunction : LayoutFile -> CodeGen.Expression
callLayoutFunction layout =
    "{{moduleName}}.layout settings.{{lastPartField}} model.shared route"
        |> String.replace "{{moduleName}}" (LayoutFile.toModuleName layout)
        |> String.replace "{{lastPartField}}" (LayoutFile.toLastPartFieldName layout)
        |> CodeGen.Expression.value


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
                , [ { name = "Main.Pages.Model.NotFound_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  , { name = "Main.Pages.Model.Redirecting_"
                    , arguments = []
                    , expression = CodeGen.Expression.value "Sub.none"
                    }
                  , { name = "Main.Pages.Model.Loading_ _"
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
                    toSubscriptionExpression layout

                selfAndParentLayouts ->
                    CodeGen.Expression.multilineFunction
                        { name = "Sub.batch"
                        , arguments = [ CodeGen.Expression.multilineList (List.map toSubscriptionExpression (List.reverse selfAndParentLayouts)) ]
                        }

        toSubscriptionExpression : LayoutFile -> CodeGen.Expression
        toSubscriptionExpression layout =
            CodeGen.Expression.pipeline
                [ CodeGen.Expression.function
                    { name = "Layout.subscriptions"
                    , arguments =
                        [ CodeGen.Expression.parens [ callLayoutFunction layout ]
                        , CodeGen.Expression.value ("layoutModel.{{lastPartFieldName}}" |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layout))
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
                        , ( "layout"
                          , if List.isEmpty layouts then
                                CodeGen.Expression.value "Nothing"

                            else
                                CodeGen.Expression.value "Page.layout page |> Maybe.map (initLayout model)"
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
            List.concat
                [ List.map toBranch pages
                , [ { name = "Route.Path.NotFound_"
                    , arguments = []
                    , expression =
                        CodeGen.Expression.multilineRecord
                            [ ( "page"
                              , CodeGen.Expression.tuple
                                    [ CodeGen.Expression.value "Main.Pages.Model.NotFound_"
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
layoutModelConstructor : { sendingMessage : LayoutFile, currentLayout : LayoutFile } -> CodeGen.Expression
layoutModelConstructor layoutOptions =
    CodeGen.Expression.lambda
        { arguments = [ CodeGen.Argument.new "newModel" ]
        , expression =
            "Just (Main.Layouts.Model.{{name}} { layoutModel | {{lastPartFieldName}} = newModel })"
                |> String.replace "{{name}}" (LayoutFile.toVariantName layoutOptions.currentLayout)
                |> String.replace "{{lastPartFieldName}}" (LayoutFile.toLastPartFieldName layoutOptions.sendingMessage)
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
            , arguments = [ CodeGen.Expression.value ("Main.Pages.Msg." ++ routeVariantName) ]
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
        , exposing_ = [ ".." ]
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
