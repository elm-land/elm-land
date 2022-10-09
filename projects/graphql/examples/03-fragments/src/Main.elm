module Main exposing (..)

import GraphQL.Http
import GraphQL.Http.Error
import GraphQL.Queries.FetchUsers


type Msg
    = ApiResponded (Result GraphQL.Http.Error GraphQL.Queries.FetchUsers.Data)


config : GraphQL.Http.Config
config =
    GraphQL.Http.get
        { url = "http://localhost:3000/graphql"
        }


sendMeQuery : Cmd Msg
sendMeQuery =
    GraphQL.Http.run config
        { operation = GraphQL.Queries.FetchUsers.new
        , onResponse = ApiResponded
        }
