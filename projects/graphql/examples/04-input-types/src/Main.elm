module Main exposing (..)

import Api.Input
import Api.Input.UserSignInForm
import Api.Mutations.SignIn exposing (Data)
import Api.Mutations.SignIn.Input
import GraphQL.Operation exposing (Operation)
import Http


type Msg
    = ApiResponded (Result Http.Error Data)


sendGraphQL : Cmd Msg
sendGraphQL =
    let
        signInMutation : Operation Data
        signInMutation =
            let
                input : Api.Mutations.SignIn.Input
                input =
                    Api.Mutations.SignIn.Input.new
                        |> Api.Mutations.SignIn.Input.form userSignInForm

                userSignInForm : Api.Input.UserSignInForm
                userSignInForm =
                    Api.Input.UserSignInForm.new
                        |> Api.Input.UserSignInForm.email "ryan@elm.land"
                        |> Api.Input.UserSignInForm.password "supersecret123"
            in
            Api.Mutations.SignIn.new input
    in
    GraphQL.Operation.toHttpCmd
        { method = "POST"
        , url = "/api/graphql"
        , headers = []
        , tracker = Nothing
        , timeout = Nothing
        , operation = signInMutation
        , onResponse = ApiResponded
        }
