port module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Html.Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import View exposing (View)


port outgoing : String -> Cmd msg


port incoming : (String -> msg) -> Sub msg


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
    String


init : () -> ( Model, Effect Msg )
init () =
    ( ""
    , Effect.none
    )



-- UPDATE


type Msg
    = UserClickedAskQuestion
    | GotData String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserClickedAskQuestion ->
            ( model
            , Effect.sendCmd (outgoing "Ask me a question!")
            )

        GotData str ->
            ( str
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    incoming GotData



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body =
        [ Html.button
            [ Html.Events.onClick UserClickedAskQuestion
            ]
            [ Html.text "Ask me a question!" ]
        , Html.br [] []
        , Html.text model
        ]
    }
