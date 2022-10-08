module GraphQL.Queries.FetchUsers exposing
    ( Data, new
    , User, Follower
    )

{-|

@docs Data, new
@docs User, Follower

-}

import GraphQL
import GraphQL.Internals.Http
import GraphQL.Scalar
import GraphQL.Scalar.ID


type alias Data =
    { users : List User
    }


type alias User =
    { id : GraphQL.Scalar.ID
    , username : String
    , avatarUrl : Maybe String
    , followers : List Follower
    }


type alias Follower =
    { id : GraphQL.Scalar.ID
    , username : String
    , avatarUrl : Maybe String
    }


new : GraphQL.Query Data
new =
    GraphQL.Internals.Http.operation
        { name = "FetchCurrentUser"
        , query = """
            query FetchUsers {
                users {
                    id
                    username
                    avatarUrl
                    followers {
                        ...Follower
                    }
                }
            }

            fragment Follower on User {
                id
                username
                avatarUrl
            }
        """
        , variables = Nothing
        , decoder =
            GraphQL.Internals.Http.object Data
                |> GraphQL.Internals.Http.field "users"
                    { wrapper = GraphQL.Internals.Http.list
                    , decoder =
                        GraphQL.Internals.Http.object User
                            |> GraphQL.Internals.Http.field "id"
                                { wrapper = GraphQL.Internals.Http.none
                                , decoder = GraphQL.Internals.Http.scalars.custom GraphQL.Scalar.ID.decoder
                                }
                            |> GraphQL.Internals.Http.field "username"
                                { wrapper = GraphQL.Internals.Http.none
                                , decoder = GraphQL.Internals.Http.scalars.string
                                }
                            |> GraphQL.Internals.Http.field "avatarUrl"
                                { wrapper = GraphQL.Internals.Http.maybe
                                , decoder = GraphQL.Internals.Http.scalars.string
                                }
                            |> GraphQL.Internals.Http.field "followers"
                                { wrapper = GraphQL.Internals.Http.list
                                , decoder =
                                    GraphQL.Internals.Http.object Follower
                                        |> GraphQL.Internals.Http.field "id"
                                            { wrapper = GraphQL.Internals.Http.none
                                            , decoder = GraphQL.Internals.Http.scalars.custom GraphQL.Scalar.ID.decoder
                                            }
                                        |> GraphQL.Internals.Http.field "username"
                                            { wrapper = GraphQL.Internals.Http.none
                                            , decoder = GraphQL.Internals.Http.scalars.string
                                            }
                                        |> GraphQL.Internals.Http.field "avatarUrl"
                                            { wrapper = GraphQL.Internals.Http.maybe
                                            , decoder = GraphQL.Internals.Http.scalars.string
                                            }
                                }
                    }
        }
