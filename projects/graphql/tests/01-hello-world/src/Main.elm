module Main exposing (main)

import Browser
import GraphQL.Operation
import GraphQL.Queries.HelloWorld
import Html exposing (..)
import Http


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }



-- MODEL


type alias Model =
    { response : Response GraphQL.Queries.HelloWorld.Data
    }


type Response data
    = Loading
    | Success data
    | Failure Http.Error


init : () -> ( Model, Cmd Msg )
init _ =
    ( { response = Loading }
    , GraphQL.Operation.toHttpCmd
        { operation = GraphQL.Queries.HelloWorld.new
        , onResponse = ApiResponded
        , method = "POST"
        , url = "/graphql"
        , headers = []
        , timeout = Nothing
        , tracker = Nothing
        }
    )



-- UPDATE


type Msg
    = ApiResponded
        (Result
            Http.Error
            GraphQL.Queries.HelloWorld.Data
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ApiResponded (Ok data) ->
            ( { model | response = Success data }
            , Cmd.none
            )

        ApiResponded (Err httpError) ->
            ( { model | response = Failure httpError }
            , Cmd.none
            )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Response" ]
        , case model.response of
            Loading ->
                text "Loading..."

            Failure _ ->
                text "HTTP error"

            Success data ->
                text data.hello
        ]
