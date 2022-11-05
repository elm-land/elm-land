module Commands.AddLayout exposing (run)

import CodeGen
import CodeGen.Annotation
import CodeGen.Argument
import CodeGen.Declaration
import CodeGen.Expression
import CodeGen.Import
import CodeGen.Module
import Json.Decode


run : Json.Decode.Value -> List CodeGen.Module
run json =
    case Json.Decode.decodeValue decoder json of
        Ok data ->
            [ newLayoutModule data ]

        Err _ ->
            []



-- DATA


type alias Data =
    { name : String
    }


decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "name" Json.Decode.string)



-- CODEGEN


{-|

    module Layouts.Header exposing (Model, Msg, Settings, layout)

    import Effect exposing (Effect)
    import Html exposing (..)
    import Html.Attributes exposing (class)
    import Layout exposing (Layout)
    import Route exposing (Route)
    import Shared
    import View exposing (View)

    type alias Settings =
        ()

    layout : Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg
    layout settings shared route =
        Layout.new
            { init = init
            , update = update
            , view = view
            , subscriptions = subscriptions
            }

    -- INIT
    type alias Model =
        {}

    init : () -> ( Model, Effect Msg )
    init _ =
        ( {}
        , Effect.none
        )

    -- UPDATE
    type Msg
        = ReplaceMe

    update : Msg -> Model -> ( Model, Effect Msg )
    update msg model =
        case msg of
            ReplaceMe ->
                ( model
                , Effect.none
                )

    -- SUBSCRIPTIONS
    subscriptions : Model -> Sub Msg
    subscriptions model =
        Sub.none

    -- VIEW
    view :
        { toMainMsg : Msg -> mainMsg
        , content : View mainMsg
        , model : Model
        }
        -> View mainMsg
    view { toMainMsg, model, content } =
        { title = content.title
        , body =
            [ Html.text "Header"
            , Html.div [ class "page" ] content.body
            ]
        }

-}
newLayoutModule : Data -> CodeGen.Module
newLayoutModule data =
    CodeGen.Module.new
        { name = [ "Layouts", data.name ]
        , exposing_ = [ "layout" ]
        , imports =
            [ CodeGen.Import.new [ "Html" ]
                |> CodeGen.Import.withExposing [ "Html" ]
            , CodeGen.Import.new [ "Html", "Attributes" ]
                |> CodeGen.Import.withAlias "Attr"
            , CodeGen.Import.new [ "View" ]
                |> CodeGen.Import.withExposing [ "View" ]
            ]
        , declarations =
            [ CodeGen.Declaration.function
                { name = "layout"
                , annotation =
                    CodeGen.Annotation.function
                        [ CodeGen.Annotation.record
                            [ ( "page", CodeGen.Annotation.type_ "View msg" )
                            ]
                        , CodeGen.Annotation.type_ "View msg"
                        ]
                , arguments = [ CodeGen.Argument.new "{ page }" ]
                , expression =
                    CodeGen.Expression.multilineRecord
                        [ ( "title", CodeGen.Expression.value "page.title" )
                        , ( "body"
                          , CodeGen.Expression.list
                                [ CodeGen.Expression.function
                                    { name = "Html.div"
                                    , arguments =
                                        [ CodeGen.Expression.list
                                            [ CodeGen.Expression.function
                                                { name = "Attr.class"
                                                , arguments = [ CodeGen.Expression.string "page" ]
                                                }
                                            ]
                                        , CodeGen.Expression.value "page.body"
                                        ]
                                    }
                                ]
                          )
                        ]
                }
            ]
        }
