module Layouts.Sidebar.Header exposing (Model, Msg, Settings, layout)

import Effect exposing (Effect)
import Html exposing (Html)
import Html.Attributes exposing (class, style)
import Layout exposing (Layout)
import Layouts.Sidebar
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Settings =
    { title : String
    }


layout : Settings -> Shared.Model -> Route () -> Layout Layouts.Sidebar.Settings Model Msg contentMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view settings
        , subscriptions = subscriptions
        }
        |> Layout.withParentSettings {}



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


view : Settings -> { toContentMsg : Msg -> contentMsg, content : View contentMsg, model : Model } -> View contentMsg
view settings { toContentMsg, model, content } =
    { title = content.title
    , body =
        [ Html.node "style"
            []
            [ Html.text """
            header { padding: 1.5rem; border-bottom: solid 1px #eee; font-size: 2rem; font-weight: bold }
            .page { padding: 1rem; }
            """ ]
        , Html.header [] [ Html.text settings.title ]
        , Html.div [ class "page" ] content.body
        ]
    }
