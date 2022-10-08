module GraphQL exposing (Mutation, Query, map)

import GraphQL.Internals.Http


type alias Query data =
    GraphQL.Internals.Http.Operation data


type alias Mutation data =
    GraphQL.Internals.Http.Operation data


map :
    (data1 -> data2)
    -> GraphQL.Internals.Http.Operation data1
    -> GraphQL.Internals.Http.Operation data2
map fn operation =
    GraphQL.Internals.Http.mapOperation fn operation
