module Layouts.Sidebar.Header exposing (Model, Msg, Props, layout, map)

import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (..)
import Layout exposing (Layout)
import Layouts.Sidebar
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Props contentMsg =
    { title : String
    , shouldPadContent : Bool
    , button : Html contentMsg
    }


map : (msg1 -> msg2) -> Props msg1 -> Props msg2
map fn props =
    { title = props.title
    , shouldPadContent = props.shouldPadContent
    , button = Html.map fn props.button
    }


layout : Props contentMsg -> Shared.Model -> Route () -> Layout (Layouts.Sidebar.Props contentMsg) Model Msg contentMsg
layout props shared route =
    Layout.new
        { init = init
        , update = update
        , view = view props
        , subscriptions = subscriptions
        }
        |> Layout.withParentProps {}



-- MODEL


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


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Props contentMsg -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view props { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ Html.header []
            [ Html.text props.title
            , props.button
            ]
        , Html.div
            [ class "page"
            , classList [ ( "pad-16", props.shouldPadContent ) ]
            ]
            content.body
        ]
    }
