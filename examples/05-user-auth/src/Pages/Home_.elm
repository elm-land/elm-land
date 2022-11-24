module Pages.Home_ exposing (Model, Msg, page)

import Auth
import Components.Navbar
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events
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
    = UserClickedSignOut


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserClickedSignOut ->
            ( model
            , Effect.signOutUser
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Auth.User -> Model -> View Msg
view user model =
    { title = "Dashboard"
    , body =
        [ Components.Navbar.view
            { page = viewPage user
            }
        ]
    }


viewPage : Auth.User -> Html Msg
viewPage user =
    Html.section [ Attr.class "hero is-light" ]
        [ Html.div [ Attr.class "hero-body has-text-centered" ]
            [ Html.h1 [ Attr.class "title" ] [ Html.text "Dashboard" ]
            , Html.h2 [ Attr.class "subtitle" ]
                [ Html.text ("Welcome back, " ++ user.name ++ "!")
                ]
            , Html.button
                [ Attr.class "button"
                , Html.Events.onClick UserClickedSignOut
                ]
                [ Html.text "Sign out" ]
            ]
        ]
