module Pages.Home_ exposing (Model, Msg, page)

import Html
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)
import Page exposing (Page)
import View exposing (View)



-- MODEL


type alias Model =
    { name : String
    }



-- MSG


type Msg
    = UpdateName String


page : Page Model Msg
page =
    Page.sandbox
        { init = init
        , view = view
        , update = update
        }



-- INIT


init : Model
init =
    { name = "world"
    }



-- UPDATE


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateName name ->
            { model | name = name }



-- VIEW


view : Model -> View Msg
view model =
    { title = "Homepage"
    , body =
        [ Html.div []
            [ Html.text <| "Hello!!!!!  "
            ]
        , Html.input
            [ value model.name
            , onInput UpdateName
            ]
            []
        ]
    }
