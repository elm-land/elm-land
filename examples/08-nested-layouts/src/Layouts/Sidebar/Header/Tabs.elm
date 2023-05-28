module Layouts.Sidebar.Header.Tabs exposing (Model, Msg, Settings, layout)

import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (class)
import Layout exposing (Layout)
import Layouts.Sidebar.Header
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Settings =
    {}


layout : Settings -> Shared.Model -> Route () -> Layout Layouts.Sidebar.Header.Settings Model Msg contentMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
        |> Layout.withParentSettings (Debug.todo "TODO: Add Layouts.Sidebar.Header.Settings")



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


view : { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ Html.text "Sidebar.Header.Tabs"
        , Html.div [ class "page" ] content.body
        ]
    }
