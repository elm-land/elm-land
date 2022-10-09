module Main exposing (..)

import GraphQL.Http
import GraphQL.Input
import GraphQL.Input.UserSignInForm
import GraphQL.Mutations.SignIn
import GraphQL.Mutations.SignIn.Input


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Mutations.SignIn.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:1234/graphql"
        }


sendSignInMutation : Cmd Msg
sendSignInMutation =
    let
        input : GraphQL.Mutations.SignIn.Input
        input =
            GraphQL.Mutations.SignIn.Input.new
                |> GraphQL.Mutations.SignIn.Input.form userSignInForm

        userSignInForm : GraphQL.Input.UserSignInForm
        userSignInForm =
            GraphQL.Input.UserSignInForm.new
                |> GraphQL.Input.UserSignInForm.email "ryan@elm.land"
                |> GraphQL.Input.UserSignInForm.password "supersecret123"
    in
    GraphQL.Http.run config
        { operation = GraphQL.Mutations.SignIn.new input
        , onResponse = ApiResponded
        }
