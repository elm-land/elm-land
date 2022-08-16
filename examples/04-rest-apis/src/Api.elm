module Api exposing (Data(..), get)

import Http
import Json.Decode


type Data value
    = Loading
    | Success value
    | Failure Http.Error


fromResult : Result Http.Error value -> Data value
fromResult result =
    case result of
        Ok value ->
            Success value

        Err httpError ->
            Failure httpError


get :
    { url : String
    , onResponse : Data value -> msg
    , decoder : Json.Decode.Decoder value
    }
    -> Cmd msg
get options =
    Http.get
        { url = options.url
        , expect =
            Http.expectJson
                (\httpResult ->
                    options.onResponse
                        (fromResult httpResult)
                )
                options.decoder
        }
