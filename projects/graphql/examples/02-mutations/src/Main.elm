module Main exposing (..)

import Api.Mutations.SignUp exposing (Data)
import Api.Mutations.SignUp.Input
import GraphQL.Operation exposing (Operation)
import Http


type Msg
    = ApiResponded (Result Http.Error Data)


sendGraphQL : Cmd Msg
sendGraphQL =
    let
        operation : Operation Data
        operation =
            let
                input : Api.Mutations.SignUp.Input
                input =
                    Api.Mutations.SignUp.Input.new
                        |> Api.Mutations.SignUp.Input.email "ryan@elm.land"
                        |> Api.Mutations.SignUp.Input.password "supersecret123"
            in
            Api.Mutations.SignUp.new input
    in
    GraphQL.Operation.toHttpCmd
        { method = "POST"
        , url = "/api/graphql"
        , headers = []
        , tracker = Nothing
        , timeout = Nothing
        , operation = operation
        , onResponse = ApiResponded
        }
