module Pages.Home_ exposing (Model, Msg, page)

import Effect exposing (Effect)
import Html
import Html.Attributes exposing (class)
import Html.Events
import Layouts
import Page exposing (Page)
import Route exposing (Route)
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
        |> Page.withLayout toLayout


toLayout : Model -> Layouts.Layout Msg
toLayout model =
    Layouts.Sidebar_Header
        { title = "Dashboard"
        , shouldPadContent = True
        , button =
            Html.button [ class "btn", Html.Events.onClick Increment ]
                [ Html.text ("Counter: " ++ String.fromInt model.counter)
                ]
        }



-- INIT


type alias Model =
    { counter : Int
    }


init : () -> ( Model, Effect Msg )
init () =
    ( { counter = 0 }
    , Effect.none
    )



-- UPDATE


type Msg
    = Increment


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | counter = model.counter + 1 }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Dashboard"
    , body =
        [ Html.div [ class "page" ]
            [ Html.text "Welcome to the dashboard!" ]
        ]
    }
