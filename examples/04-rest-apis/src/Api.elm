module Api exposing (Data(..), toHelpfulMessage)

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


toHelpfulMessage : Http.Error -> String
toHelpfulMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            "Something is wrong with the API URL"

        Http.Timeout ->
            "API response timed out"

        Http.NetworkError ->
            "Could not connect to API"

        Http.BadStatus code ->
            if code == 404 then
                "Not found"

            else
                "Server returned bad status code"

        Http.BadBody _ ->
            "Unexpected JSON response from API"
