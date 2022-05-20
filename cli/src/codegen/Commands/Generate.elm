module Commands.Generate exposing (Options, main, run)

{-| -}

import Elm
import Elm.Annotation
import Elm.Case
import Elm.Gen
import Gen.Maybe
import Gen.Url.Parser
import RoutePath exposing (RoutePath)


main : Program {} () ()
main =
    Platform.worker
        { init =
            \json ->
                ( ()
                , Elm.Gen.files
                    (files
                        [ RoutePath.fromList [ "Home_" ]
                        , RoutePath.fromList [ "SignIn" ]
                        , RoutePath.fromList [ "Settings" ]
                        , RoutePath.fromList [ "People", "Username_" ]
                        ]
                    )
                )
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


type alias Options =
    { pageRoutePaths : List RoutePath
    }


run : Options -> Cmd msg
run { pageRoutePaths } =
    Elm.Gen.files (files pageRoutePaths)


files : List RoutePath -> List Elm.File
files routePaths =
    [ mainElm routePaths
    , routeElm routePaths
    , notFoundElm
    ]



-- src/Pages/NotFound_.elm


notFoundElm : Elm.File
notFoundElm =
    Elm.file [ "Pages", "NotFound_" ]
        [ Elm.declaration "page"
            (Elm.apply
                (Elm.value
                    { importFrom = [ "Html" ]
                    , name = "text"
                    , annotation = Just annotations.htmlMsgGeneric
                    }
                )
                [ Elm.string "Page not found..."
                ]
            )
        ]



-- ROUTE.ELM


routeElm : List RoutePath -> Elm.File
routeElm routePaths =
    Elm.file [ "Route" ]
        [ Elm.unsafe "import Url.Parser exposing ((</>))"
        , routeType routePaths
            |> Elm.exposeWith
                { exposeConstructor = True
                , group = Nothing
                }
        , fromUrlFn
            |> Elm.expose
        , routeParserFn routePaths
        ]


routeType : List RoutePath -> Elm.Declaration
routeType paths =
    let
        toRouteVariant : RoutePath -> Elm.Variant
        toRouteVariant routePath =
            if RoutePath.hasDynamicParameters routePath then
                Elm.variantWith (RoutePath.toRouteVariantName routePath)
                    [ RoutePath.toDynamicParameterRecord routePath
                    ]

            else
                Elm.variant (RoutePath.toRouteVariantName routePath)
    in
    Elm.customType "Route"
        (List.map toRouteVariant paths ++ [ toRouteVariant RoutePath.notFound ])


{-|

    Url.Parser.parse routeParser url
        |> Maybe.withDefault NotFound_

-}
fromUrlFn : Elm.Declaration
fromUrlFn =
    Elm.declaration "fromUrl"
        (Elm.fn "url"
            (\url ->
                Gen.Maybe.withDefault
                    (Elm.value
                        { importFrom = []
                        , name = "NotFound_"
                        , annotation = Nothing
                        }
                    )
                    (Gen.Url.Parser.parse
                        (Elm.value { importFrom = [], name = "routeParser", annotation = Nothing })
                        url
                        |> Elm.withType
                            (Elm.Annotation.maybe
                                (Elm.Annotation.named [] "Route")
                            )
                    )
            )
        )


routeParserFn : List RoutePath -> Elm.Declaration
routeParserFn paths =
    Elm.declaration "routeParser"
        (Elm.apply
            (Elm.value
                { importFrom = [ "Url", "Parser" ]
                , name = "oneOf"
                , annotation =
                    Nothing
                }
            )
            [ Elm.list
                (List.map
                    RoutePath.toUrlParser
                    paths
                )
            ]
            |> Elm.withType
                (Gen.Url.Parser.annotation_.parser
                    (Elm.Annotation.function
                        [ Elm.Annotation.named [] "Route"
                        ]
                        (Elm.Annotation.var "x")
                    )
                    (Elm.Annotation.var "x")
                )
        )



-- MAIN.ELM


mainElm : List RoutePath -> Elm.File
mainElm routePaths =
    Elm.file [ "Main" ]
        [ flagsAlias
        , Elm.expose mainFn
        , Elm.comment "INIT"
        , modelTypeAlias
        , initFn
        , Elm.comment "UPDATE"
        , msgType
        , updateFn
        , subscriptionsFn
        , Elm.comment "VIEW"
        , viewFn
        , viewPageFn routePaths
        ]


flagsAlias : Elm.Declaration
flagsAlias =
    Elm.alias "Flags"
        (Elm.Annotation.named [ "Json.Decode" ] "Value")


mainFn : Elm.Declaration
mainFn =
    let
        programTypeAnnotation : Elm.Annotation.Annotation
        programTypeAnnotation =
            Elm.Annotation.namedWith []
                "Program"
                [ annotations.flags
                , annotations.model
                , annotations.msg
                ]
    in
    Elm.declaration "main"
        (Elm.apply
            (Elm.value
                { importFrom = [ "Browser" ]
                , name = "application"
                , annotation = Nothing
                }
            )
            [ Elm.record
                [ Elm.field "init" (ref "init")
                , Elm.field "update" (ref "update")
                , Elm.field "view" (ref "view")
                , Elm.field "subscriptions" (ref "subscriptions")
                , Elm.field "onUrlChange" (ref "UrlChanged")
                , Elm.field "onUrlRequest" (ref "UrlRequested")
                ]
            ]
            |> Elm.withType programTypeAnnotation
        )


modelTypeAlias : Elm.Declaration
modelTypeAlias =
    Elm.alias "Model"
        (Elm.Annotation.record
            [ ( "flags", Elm.Annotation.named [] "Flags" )
            , ( "key", annotations.browserKey )
            , ( "url", annotations.url )
            ]
        )


initFn : Elm.Declaration
initFn =
    Elm.unsafe """
init : Flags -> Url.Url -> Browser.Navigation.Key -> (Model, Cmd Msg)
init flags url key =
    ( { flags = flags
      , url = url
      , key = key
      }
    , Cmd.none
    )
"""


msgType : Elm.Declaration
msgType =
    Elm.customType "Msg"
        [ Elm.variantWith "UrlRequested" [ annotations.urlRequest ]
        , Elm.variantWith "UrlChanged" [ annotations.url ]
        ]


updateFn : Elm.Declaration
updateFn =
    -- Elm.declaration "update"
    --     (Elm.fn2 "msg"
    --         "model"
    --         (\msg model ->
    -- Elm.Case.custom msg
    --     [ Elm.Case.branch1 []
    --         "UrlChanged"
    --         (\url ->
    --             Elm.tuple
    --                 (Elm.updateRecord model
    --                     [ Elm.field "url" url
    --                     ]
    --                 )
    --                 values.cmdNone
    --         )
    --     ,
    --     -- Elm.Case.branch1 []
    --     --     "UrlRequested"
    --     --     (\url ->
    --     --         Elm.tuple
    --     --             model
    --     --             (Elm.apply
    --     --                 (Elm.value
    --     --                     { importFrom = [ "Browser", "Navigation" ]
    --     --                     , name = "pushUrl"
    --     --                     , annotation = Nothing
    --     --                     }
    --     --                 )
    --     --                 [ model |> Elm.get "key"
    --     --                 , url
    --     --                 ]
    --     --             )
    --     --     )
    --     ]
    --     )
    --     |> Elm.withType
    --         (Elm.Annotation.function
    --             [ annotations.msg
    --             , annotations.model
    --             ]
    --             (Elm.Annotation.tuple annotations.model annotations.cmdMsg)
    --         )
    -- )
    Elm.unsafe """
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , Browser.Navigation.pushUrl model.key (Url.toString url)
            )

        UrlRequested (Browser.External url) ->
            ( model
            , Browser.Navigation.load url
            )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )
"""


subscriptionsFn : Elm.Declaration
subscriptionsFn =
    Elm.declaration "subscriptions"
        (Elm.fn "model"
            (\model -> values.subNone)
        )


viewFn : Elm.Declaration
viewFn =
    Elm.declaration "view"
        (Elm.fn "model"
            (\model ->
                Elm.record
                    [ Elm.field "title" (Elm.string "App")
                    , Elm.field "body"
                        (Elm.list
                            [ Elm.apply
                                (Elm.value
                                    { importFrom = []
                                    , name = "viewPage"
                                    , annotation = Nothing
                                    }
                                )
                                [ model
                                ]
                            ]
                        )
                    ]
            )
            |> Elm.withType (Elm.Annotation.function [ annotations.model ] annotations.documentMsg)
        )


viewPageFn : List RoutePath -> Elm.Declaration
viewPageFn routePaths =
    let
        branches : List Elm.Case.Branch
        branches =
            List.map toBranch routePaths ++ [ toBranch RoutePath.notFound ]

        {-
           Route.Home_ ->
               Pages.Home_.page
        -}
        toBranch : RoutePath -> Elm.Case.Branch
        toBranch routePath =
            if RoutePath.hasDynamicParameters routePath then
                Elm.Case.branch1 [ "Route" ]
                    (RoutePath.toRouteVariantName routePath)
                    (\params ->
                        Elm.apply
                            (Elm.value
                                { importFrom = "Pages" :: RoutePath.toList routePath
                                , name = "page"
                                , annotation = Nothing
                                }
                            )
                            [ params ]
                    )

            else
                Elm.Case.branch0 [ "Route" ]
                    (RoutePath.toRouteVariantName routePath)
                    (Elm.value
                        { importFrom = "Pages" :: RoutePath.toList routePath
                        , name = "page"
                        , annotation = Just annotations.htmlMsg
                        }
                    )

        routeFromUrl : Elm.Expression -> Elm.Expression
        routeFromUrl model =
            Elm.apply
                (Elm.value
                    { importFrom = [ "Route" ]
                    , name = "fromUrl"
                    , annotation = Just annotations.route
                    }
                )
                [ model |> Elm.get "url" ]
    in
    Elm.declaration "viewPage"
        (Elm.fn "model"
            (\model ->
                Elm.Case.custom (routeFromUrl model) branches
                    |> Elm.withType annotations.htmlMsg
            )
            |> Elm.withType (Elm.Annotation.function [ annotations.model ] annotations.htmlMsg)
        )


isLastPieceDynamic : List String -> Bool
isLastPieceDynamic pieces =
    case List.drop (List.length pieces - 1) pieces of
        [] ->
            False

        item :: _ ->
            if List.member item [ "Home_", "NotFound_" ] then
                False

            else
                String.endsWith "_" item



-- REUSED


annotations =
    { flags = Elm.Annotation.named [] "Flags"
    , model = Elm.Annotation.named [] "Model"
    , msg = Elm.Annotation.named [] "Msg"
    , browserKey = Elm.Annotation.named [ "Browser.Navigation" ] "Key"
    , urlRequest = Elm.Annotation.named [ "Browser" ] "UrlRequest"
    , documentMsg = Elm.Annotation.namedWith [ "Browser" ] "Document" [ Elm.Annotation.named [] "Msg" ]
    , htmlMsg = Elm.Annotation.namedWith [ "Html" ] "Html" [ Elm.Annotation.named [] "Msg" ]
    , htmlMsgGeneric = Elm.Annotation.namedWith [ "Html" ] "Html" [ Elm.Annotation.var "msg" ]
    , url = Elm.Annotation.named [ "Url" ] "Url"
    , subMsg =
        Elm.Annotation.namedWith []
            "Sub"
            [ Elm.Annotation.named [] "Msg"
            ]
    , cmdMsg =
        Elm.Annotation.namedWith []
            "Cmd"
            [ Elm.Annotation.named [] "Msg"
            ]
    , route =
        Elm.Annotation.named [ "Route" ] "Route"
    }


values =
    { cmdNone =
        Elm.value
            { importFrom = []
            , name = "Cmd.none"
            , annotation = Just annotations.cmdMsg
            }
    , subNone =
        Elm.value
            { importFrom = []
            , name = "Sub.none"
            , annotation = Just annotations.subMsg
            }
    }



-- HELPERS


ref : String -> Elm.Expression
ref name =
    Elm.value { importFrom = [], name = name, annotation = Nothing }
