port module Worker exposing (main)

import Error exposing (Error)
import Json.Decode
import Json.Encode
import Platform


port onComplete : List Json.Encode.Value -> Cmd msg


main : Program Json.Decode.Value Model Msg
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
    , [ Error.new
            { path = "src/Pages/Home_.elm"
            , title = "Missing page function"
            , message =
                [ Error.text "In order for Elm Land to build, every page needs to expose a "
                , Error.yellow "`page`"
                , Error.text " function.\n"
                , Error.text """Please be sure to include "page" in your exposing list like this:

1|  module Pages.Home_ exposing (page)
                                 """
                , Error.green """^^^^"""
                , Error.text "\n"
                , Error.underline "Hint:"
                , Error.text " Read https://elm.land/errors/missing-page-function to learn more"
                ]
            }
      ]
        |> List.map Error.toJson
        |> onComplete
    )



-- UPDATE


type Msg
    = DoNothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
