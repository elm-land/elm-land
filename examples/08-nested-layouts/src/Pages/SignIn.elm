module Pages.SignIn exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
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
    { title = "Pages.SignIn"
    , body =
        [ Html.node "style"
            []
            [ Html.text """
            html, body { height: 100%; }
            body {
              margin: 0;
              font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
              display: flex;
              justify-content: center;
              align-items: center;
            }
            * { box-sizing: border-box; color: inherit; }
            a { background: dodgerblue; padding: 0.7rem 1.2rem; color: white; border-radius: 0.5rem; }
            a:hover { opacity: 0.75; }
            """ ]
        , Html.a
            [ Route.Path.href Route.Path.Home_
            ]
            [ Html.text "Sign in" ]
        ]
    }
