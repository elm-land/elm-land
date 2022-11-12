module Pages.Profile exposing (Model, Msg, page)

import Auth
import Components.Navbar
import Effect exposing (Effect)
import Html
import Html.Attributes as Attr
import Page exposing (Page)
import Route exposing (Route)
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
    { title = "Profile"
    , body =
        [ Components.Navbar.view
            { page =
                Html.section [ Attr.class "hero is-light" ]
                    [ Html.div [ Attr.class "hero-body has-text-centered is-flex is-flex-direction-column is-align-items-center" ]
                        [ Html.figure [ Attr.class "image is-128x128 is-block p-4" ]
                            [ Html.img [ Attr.class "is-rounded", Attr.src user.profileImageUrl ] []
                            ]
                        , Html.h1 [ Attr.class "title" ] [ Html.text user.name ]
                        , Html.h2 [ Attr.class "subtitle" ] [ Html.text user.email ]
                        ]
                    ]
            }
        ]
    }
