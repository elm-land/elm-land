module Worker exposing (main)

import Command
import Elm.Gen
import Json.Decode


main : Program Json.Decode.Value () ()
main =
    Platform.worker
        { init =
            \json ->
                ( ()
                , case Command.fromJson json of
                    Ok command ->
                        Command.run command

                    Err jsonError ->
                        Elm.Gen.error
                            [ { title = "Did not understand command"
                              , description = Json.Decode.errorToString jsonError
                              }
                            ]
                )
        , update = \msg model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
