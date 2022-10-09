module GraphQL.Queries.FetchCurrentUser exposing
    ( Data, new
    , User, NotSignedIn
    )

{-|

@docs Data, new
@docs User, NotSignedIn

-}

import GraphQL
import GraphQL.Internals.Http
import GraphQL.Queries.FetchCurrentUser.UserResult
import GraphQL.Scalar
import GraphQL.Scalar.ID


type alias Data =
    { currentUser : UserResult
    }


type alias UserResult =
    GraphQL.Queries.FetchCurrentUser.UserResult.UserResult


type alias User =
    { id : GraphQL.Scalar.ID
    , name : String
    , avatarUrl : Maybe String
    }


type alias NotSignedIn =
    { message : String
    }


new : GraphQL.Query Data
new =
    GraphQL.Internals.Http.operation
        { name = "FetchCurrentUser"
        , query = """
            query FetchCurrentUser {
                currentUser {
                    __typename      # Injected by @elm-land/graphql
                    ...on User {
                        id
                        name
                        avatarUrl
                    }
                    ...on NotSignedIn {
                        message
                    }
                }
            }
        """
        , variables = Nothing
        , decoder =
            GraphQL.Internals.Http.object Data
                |> GraphQL.Internals.Http.field "currentUser"
                    { wrapper = GraphQL.Internals.Http.none
                    , decoder =
                        GraphQL.Internals.Http.union
                            [ { typename = "User"
                              , decoder =
                                    GraphQL.Internals.Http.variant
                                        GraphQL.Queries.FetchCurrentUser.UserResult.OnUser
                                        (GraphQL.Internals.Http.object User
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
                                        )
                              }
                            , { typename = "NotSignedIn"
                              , decoder =
                                    GraphQL.Internals.Http.variant
                                        GraphQL.Queries.FetchCurrentUser.UserResult.OnNotSignedIn
                                        (GraphQL.Internals.Http.object NotSignedIn
                                            |> GraphQL.Internals.Http.field "message"
                                                { wrapper = GraphQL.Internals.Http.none
                                                , decoder = GraphQL.Internals.Http.scalars.string
                                                }
                                        )
                              }
                            ]
                    }
        }
