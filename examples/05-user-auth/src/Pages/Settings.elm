module Pages.Settings exposing (Model, Msg, page)

import Auth
import Effect exposing (Effect)
import Html
import Html.Attributes as Attr
import Layout exposing (Layout)
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


layout : Layout
layout =
    Layout.Navbar


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
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


view : Model -> View Msg
view model =
    { title = "Settings"
    , body =
        [ Html.section [ Attr.class "hero is-light" ]
            [ Html.div [ Attr.class "hero-body has-text-centered" ]
                [ Html.h1 [ Attr.class "title" ] [ Html.text "Settings" ]
                , Html.h2 [ Attr.class "subtitle" ]
                    [ Html.text "Imagine there's a form here or something!"
                    ]
                ]
            ]
        ]
    }
