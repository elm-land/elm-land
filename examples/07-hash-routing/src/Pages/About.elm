module Pages.About exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html exposing (div, pre, text)
import Layout exposing (Layout)
import Page exposing (Page)
import Route exposing (Route)
import Route.Path exposing (href)
import Shared
import View exposing (View)


layout : Layout
layout =
    Layout.Sidebar


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view route
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = ExampleMsgReplaceMe


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Route () -> Model -> View Msg
view route model =
    { title = "Pages.About"
    , body =
        [ div []
            [ div [] [ text (Debug.toString route.path) ]
            , pre [] [ text (Debug.toString route) ]
            ]
        ]
    }
