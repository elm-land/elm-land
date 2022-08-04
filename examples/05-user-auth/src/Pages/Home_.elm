module Pages.Home_ exposing (Model, Msg, page)

import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Page exposing (Page)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


page : Auth.User -> Shared.Model -> Route () -> Page Model Msg
page user shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view user
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


view : Auth.User -> Model -> View Msg
view user model =
    { title = "Dashboard"
    , body = [ viewPage user ]
    }


viewPage : Auth.User -> Html msg
viewPage user =
    Html.section [ Attr.class "hero is-link" ]
        [ Html.div [ Attr.class "hero-body has-text-centered" ]
            [ Html.h1 [ Attr.class "title" ] [ Html.text "Dashboard" ]
            , Html.h2 [ Attr.class "subtitle" ]
                [ Html.text ("Welcome back, " ++ user.name ++ "!")
                ]
            , Html.a
                [ Attr.class "link is-underlined"
                , Attr.href (Route.Path.toString Route.Path.SignIn)
                ]
                [ Html.text "Back to sign in page" ]
            , Html.a [ Attr.class "button" ] [ Html.text "Sign out" ]
            ]
        ]
