module Layouts.Sidebar exposing (Model, Msg, Settings, layout)

import Auth
import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes as Attr
import Layout exposing (Layout)
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias Settings =
    { user : Auth.User
    }


layout : Settings -> Shared.Model -> Route () -> Layout Model Msg mainMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view settings
        , subscriptions = subscriptions
        }



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
            ( {}
            , Effect.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Settings -> { fromMsg : Msg -> mainMsg, content : View mainMsg, model : Model } -> View mainMsg
view settings { fromMsg, model, content } =
    { title = content.title
    , body =
        [ Html.div
            [ Attr.class "is-flex"
            , Attr.style "height" "100%"
            ]
            [ Html.aside [ Attr.class "p-5 pr-6 box" ]
                [ Html.a
                    [ Attr.class "title is-block"
                    , Route.Path.href Route.Path.Home_
                    ]
                    [ Html.text "Twooter" ]
                , Html.text ("Signed in as @" ++ settings.user.username)
                ]
            , Html.main_ [ Attr.class "page p-5 is-flex-grow-1" ] content.body
            ]
        ]
    }
