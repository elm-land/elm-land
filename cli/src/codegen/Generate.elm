module Generate exposing (main)

{-| -}

import Elm
import Elm.Annotation
import Elm.Case
import Elm.Gen
import Gen.Basics


main : Program {} () ()
main =
    Platform.worker
        { init = \json -> ( (), Elm.Gen.files files )
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }


files : List Elm.File
files =
    [ mainElm ]


mainElm : Elm.File
mainElm =
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
        , viewPageFn [ "Home_", "SignIn", "Settings" ]
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
        )


viewPageFn : List String -> Elm.Declaration
viewPageFn routes =
    Elm.declaration "viewPage"
        (Elm.fn "model"
            (\model ->
                Elm.apply
                    (Elm.value
                        { importFrom = [ "Html" ]
                        , name = "text"
                        , annotation = Nothing
                        }
                    )
                    [ Elm.string "Hello"
                    ]
                    |> Elm.withType annotations.htmlMsg
            )
        )



-- REUSED


annotations =
    { flags = Elm.Annotation.named [] "Flags"
    , model = Elm.Annotation.named [] "Model"
    , msg = Elm.Annotation.named [] "Msg"
    , browserKey = Elm.Annotation.named [ "Browser.Navigation" ] "Key"
    , urlRequest = Elm.Annotation.named [ "Browser" ] "UrlRequest"
    , documentMsg = Elm.Annotation.namedWith [ "Browser" ] "Document" [ Elm.Annotation.named [] "Msg" ]
    , htmlMsg = Elm.Annotation.namedWith [ "Html" ] "Html" [ Elm.Annotation.named [] "Msg" ]
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
