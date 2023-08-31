module Main exposing (..)

import Api.Queries.FetchUser exposing (Data)
import GraphQL.Operation exposing (Operation)


operation : Operation Data
operation =
    Api.Queries.FetchUser.new
