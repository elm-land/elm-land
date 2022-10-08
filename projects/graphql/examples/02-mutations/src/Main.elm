module Main exposing (..)

import GraphQL.Http
import GraphQL.Mutations.SignUp
import GraphQL.Mutations.SignUp.Input


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Mutations.SignUp.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:1234/graphql"
        }


sendSignUpMutation : Cmd Msg
sendSignUpMutation =
    let
        input : GraphQL.Mutations.SignUp.Input
        input =
            GraphQL.Mutations.SignUp.Input.new
                |> GraphQL.Mutations.SignUp.Input.email "ryan@elm.land"
                |> GraphQL.Mutations.SignUp.Input.password "supersecret123"
    in
    GraphQL.Http.run config
        { operation = GraphQL.Mutations.SignUp.new input
        , onResponse = ApiResponded
        }
