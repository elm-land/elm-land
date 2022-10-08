module GraphQL.Queries.FetchCurrentUser exposing
    ( Data, new
    , User
    )

{-|

@docs Data, new
@docs User

-}

import GraphQL
import GraphQL.Internals.Http
import GraphQL.Scalar
import GraphQL.Scalar.ID


type alias Data =
    { me : Maybe User
    }


type alias User =
    { id : GraphQL.Scalar.ID
    , email : String
    , avatarUrl : Maybe String
    }


new : GraphQL.Query Data
new =
    GraphQL.Internals.Http.operation
        { name = "FetchCurrentUser"
        , query = """
            query FetchCurrentUser {
              me {
                id
                email
                avatarUrl
              }
            }
        """
        , variables = Nothing
        , decoder =
            GraphQL.Internals.Http.object Data
                |> GraphQL.Internals.Http.field "me"
                    { wrapper = GraphQL.Internals.Http.maybe
                    , decoder =
                        GraphQL.Internals.Http.object User
                            |> GraphQL.Internals.Http.field "id"
                                { wrapper = GraphQL.Internals.Http.none
                                , decoder = GraphQL.Internals.Http.scalars.custom GraphQL.Scalar.ID.decoder
                                }
                            |> GraphQL.Internals.Http.field "email"
                                { wrapper = GraphQL.Internals.Http.none
                                , decoder = GraphQL.Internals.Http.scalars.string
                                }
                            |> GraphQL.Internals.Http.field "avatarUrl"
                                { wrapper = GraphQL.Internals.Http.maybe
                                , decoder = GraphQL.Internals.Http.scalars.string
                                }
                    }
        }
