module Pages.Home_ exposing (Model, Msg, page)

import Html exposing (Html)
import Html.Events
import Page exposing (Page)
import View exposing (View)


page : Page Model Msg
page =
    Page.sandbox
        { init = init
        , update = update
        , view = view
        }



-- INIT


type alias Model =
    { counter : Int
    }


init : Model
init =
    { counter = 0
    }



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            { model | counter = model.counter + 1 }

        Decrement ->
            { model | counter = model.counter - 1 }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Counter"
    , body =
        [ Html.div []
            [ Html.button
                [ Html.Events.onClick Increment ]
                [ Html.text "+" ]
            , Html.div []
                [ Html.text (String.fromInt model.counter) ]
            , Html.button
                [ Html.Events.onClick Decrement ]
                [ Html.text "-" ]
            ]
        ]
    }
