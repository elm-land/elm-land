module Pages.SignIn exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Html.Attributes exposing (class)
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
    = NoOp


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
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
    { title = "Sign in | MyCoolApp"
    , body =
        [ Html.div [ class "page page--sign-in" ]
            [ Html.a
                [ class "btn"
                , Route.Path.href Route.Path.Home_
                ]
                [ Html.text "Sign in" ]
            ]
        ]
    }
