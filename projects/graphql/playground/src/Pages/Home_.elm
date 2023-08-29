module Pages.Home_ exposing (Model, Msg, page)

import Api.Mutations.CreatePerson
import Api.Mutations.CreatePerson.Input
import Effect exposing (Effect)
import GraphQL.Operation exposing (Operation)
import Html
import Http
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



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    let
        input : Api.Mutations.CreatePerson.Input
        input =
            Api.Mutations.CreatePerson.Input.new
                |> Api.Mutations.CreatePerson.Input.name "Ryan"
                |> Api.Mutations.CreatePerson.Input.email "ryan@jangle.io"

        operation : Operation Api.Mutations.CreatePerson.Data
        operation =
            Api.Mutations.CreatePerson.new input
    in
    ( {}
    , GraphQL.Operation.toHttpCmd
        { method = "POST"
        , url = "/api/graphql"
        , headers = []
        , timeout = Just 10000
        , tracker = Nothing
        , operation = operation
        , onResponse = ApiResponded
        }
        |> Effect.sendCmd
    )



-- UPDATE


type Msg
    = ApiResponded (Result Http.Error Api.Mutations.CreatePerson.Data)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ApiResponded _ ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> View Msg
view model =
    { title = "Pages.Home_"
    , body = [ Html.text "/" ]
    }
