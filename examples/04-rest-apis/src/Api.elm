module Api exposing (Data(..), toUserFriendlyMessage)

import Http


type Data value
    = Loading
    | Success value
    | Failure Http.Error


toUserFriendlyMessage : Http.Error -> String
toUserFriendlyMessage httpError =
    case httpError of
        Http.BadUrl _ ->
            -- The URL is malformed, probably caused by a typo
            "This page requested a bad URL"

        Http.Timeout ->
            -- Happens after
            "Request took too long to respond"

        Http.NetworkError ->
            -- Happens if the user is offline or the API isn't online
            "Could not connect to the API"

        Http.BadStatus code ->
            -- Connected to the API, but something went wrong
            if code == 404 then
                "Item not found"

            else
                "API returned an error code"

        Http.BadBody _ ->
            -- Our JSON decoder didn't match what the API sent
            "Unexpected response from API"
