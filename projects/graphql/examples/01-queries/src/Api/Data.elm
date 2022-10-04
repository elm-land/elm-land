module Api.Data exposing (Data(..), fromResult)

import GraphQL.Http


type Data value
    = Loading
    | Success value
    | Failure GraphQL.Http.Error


fromResult : Result GraphQL.Http.Error value -> Data value
fromResult result =
    case result of
        Err reason ->
            Failure reason

        Ok value ->
            Success value
