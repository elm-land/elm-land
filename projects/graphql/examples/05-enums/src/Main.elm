module Main exposing (..)

import Api.Enum.Department as Department exposing (Department)
import Api.Queries.FetchUser exposing (Data)
import GraphQL.Operation exposing (Operation)
import Http


type Msg
    = ApiResponded (Result Http.Error Data)


sendGraphQL : Cmd Msg
sendGraphQL =
    let
        fetchUser : Operation Data
        fetchUser =
            Api.Queries.FetchUser.new
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


toLabel : Department -> String
toLabel department =
    case department of
        Department.PRODUCT ->
            "Product"

        Department.DESIGN ->
            "Design"

        Department.ENGINEERING ->
            "Engineering"

        Department.MARKETING ->
            "Marketing"

        Department.SALES ->
            "Sales"
