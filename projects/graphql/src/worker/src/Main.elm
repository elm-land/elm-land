port module Main exposing (main)

import Json.Decode


main : Platform.Program Json.Decode.Value Model Msg
main =
    Platform.worker
        { init = init
        , update = update
        , subscriptions = subscriptions
        }



-- INIT


type alias Model =
    {}


port outgoing : { message : String } -> Cmd msg


type alias Flags =
    { schema : GraphQL.Introspection.Schema
    , queries : List GraphQL.Introspection.Document
    , mutations : List GraphQL.Introspection.Document
    }


init : Json.Decode.Value -> ( Model, Cmd Msg )
init json =
    let
        flags : Flags
        flags =
            parseFlags json
    in
    ( {}
    , outgoing { message = "Hello!" }
    )



-- UPDATE


type alias Msg =
    Never


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
