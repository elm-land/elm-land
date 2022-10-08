module GraphQL.Http exposing
    ( Config, get, post
    , withHeader, withTimeout
    , Response, Error, run
    )

{-|

@docs Config, get, post
@docs withHeader, withTimeout
@docs Response, Error, run

-}

import GraphQL.Http.Error
import GraphQL.Http.Response
import GraphQL.Internals.Http
import Http



-- CONFIG


type Config
    = Config
        { url : String
        , headers : List Http.Header
        , method : HttpMethod
        , timeout : Maybe Int
        }


get : { url : String } -> Config
get =
    create Get


post : { url : String } -> Config
post =
    create Post


withHeader : String -> String -> Config -> Config
withHeader key value (Config cfg) =
    Config { cfg | headers = Http.header key value :: cfg.headers }


withTimeout : { ms : Int } -> Config -> Config
withTimeout timeout (Config cfg) =
    Config { cfg | timeout = Just timeout.ms }



-- MAKING REQUESTS


type alias Response data =
    GraphQL.Http.Response.Response data


type alias Error =
    GraphQL.Http.Error.Error


run :
    Config
    ->
        { operation : GraphQL.Internals.Http.Operation data
        , onResponse : Result Error data -> msg
        }
    -> Cmd msg
run (Config cfg) options =
    GraphQL.Internals.Http.request
        { url = cfg.url
        , headers = cfg.headers
        , timeout = cfg.timeout |> Maybe.map toFloat
        , method =
            case cfg.method of
                Get ->
                    "GET"

                Post ->
                    "POST"
        , operation = options.operation
        , onResult = options.onResponse
        }



-- INTERNALS


create : HttpMethod -> { url : String } -> Config
create method options =
    Config
        { url = options.url
        , method = method
        , headers = []
        , timeout = Nothing
        }


type HttpMethod
    = Get
    | Post
