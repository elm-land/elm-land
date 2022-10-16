module Layouts.Sidebar exposing (Model, Msg, Settings, layout)

import Api.Search
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (class, href, type_, value)
import Html.Events
import Http
import Layout exposing (Layout)
import Route exposing (Route)
import Shared
import View exposing (View)


type alias Settings =
    { title : String
    }


layout :
    Settings
    -> Shared.Model
    -> Route ()
    -> Layout Model Msg mainMsg
layout settings shared route =
    Layout.new
        { init = init
        , update = update
        , view = view settings
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    { search : String
    , results : Response (List Api.Search.Item)
    }


type Response value
    = NotAsked
    | Loading
    | Success value
    | Failure Http.Error


init : () -> ( Model, Effect Msg )
init _ =
    ( { search = "", results = NotAsked }
    , Effect.none
    )



-- UPDATE


type Msg
    = UserChangedSearchInput String
    | UserSubmittedSearchForm
    | SearchApiResponded (Result Http.Error (List Api.Search.Item))


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UserChangedSearchInput value ->
            if String.isEmpty value then
                ( { model | search = value, results = NotAsked }
                , Effect.none
                )

            else
                ( { model | search = value }
                , Effect.none
                )

        UserSubmittedSearchForm ->
            ( { model | results = Loading }
            , Api.Search.sendHttpRequest
                { query = model.search
                , onResponse = SearchApiResponded
                }
            )

        SearchApiResponded (Ok items) ->
            ( { model | results = Success items }
            , Effect.none
            )

        SearchApiResponded (Err reason) ->
            ( { model | results = Failure reason }
            , Effect.none
            )



-- VIEW


view :
    Settings
    ->
        { toMainMsg : Msg -> mainMsg
        , content : View mainMsg
        , model : Model
        }
    -> View mainMsg
view settings { toMainMsg, model, content } =
    { title = content.title
    , body =
        [ viewNavbar settings model
            |> Html.map toMainMsg
        , div [ class "page" ] content.body
        ]
    }


viewNavbar : Settings -> Model -> Html Msg
viewNavbar settings model =
    header [ class "navbar" ]
        [ a [ href "/" ] [ text settings.title ]
        , form [ Html.Events.onSubmit UserSubmittedSearchForm ]
            [ input
                [ type_ "search"
                , value model.search
                , Html.Events.onInput UserChangedSearchInput
                ]
                []
            , button [ type_ "submit" ] [ text "Search" ]
            ]
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
