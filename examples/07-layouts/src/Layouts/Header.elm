module Layouts.Header exposing (Model, Msg, Settings, layout)

import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class)
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias Settings =
    ()


layout : Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view settings
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
    Settings
    ->
        { toMainMsg : Msg -> mainMsg
        , content : View mainMsg
        , model : Model
        }
    -> View mainMsg
view settings { toMainMsg, model, content } =
    { title = content.title
    , body =
        [ Html.text "Header"
        , Html.div [ class "page" ] content.body
        , Html.p []
            [ a [ Route.Path.href Route.Path.Home_ ] [ text "Dashboard" ]
            , a [ Route.Path.href Route.Path.Authors ] [ text "Authors" ]
            , a [ Route.Path.href Route.Path.BlogPosts ] [ text "Posts" ]
            ]
        ]
    }
