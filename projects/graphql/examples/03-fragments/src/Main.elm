module Main exposing (..)

import Api.Queries.FetchUsers exposing (Data)
import GraphQL.Operation exposing (Operation)
import Http


type Msg
    = ApiResponded (Result Http.Error Data)


sendGraphQL : Cmd Msg
sendGraphQL =
    let
        fetchUser : Operation Data
        fetchUser =
            Api.Queries.FetchUsers.new
    in
    GraphQL.Operation.toHttpCmd
        { method = "POST"
        , url = "/api/graphql"
        , headers = []
        , tracker = Nothing
        , timeout = Nothing
        , operation = fetchUser
        , onResponse = ApiResponded
        }
