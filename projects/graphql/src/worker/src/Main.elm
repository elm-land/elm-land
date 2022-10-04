module Main exposing (main)

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


init : Json.Decode.Value -> ( Model, Cmd Msg )
init json =
    ( {}
    , Cmd.none
    )



-- UPDATE


type alias Msg =
    Never


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
