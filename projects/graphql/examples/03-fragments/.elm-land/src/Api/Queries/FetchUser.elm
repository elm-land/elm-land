module Api.Queries.FetchUser exposing
    ( Data, new
    , User, Follower
    )

{-|

@docs Data, new
@docs User, Follower

-}

import GraphQL.Decode
import GraphQL.Operation
import GraphQL.Scalar.Id


type alias Data =
    { user : User
    }


type alias User =
    { id : GraphQL.Scalar.Id.Id
    , username : String
    , avatarUrl : Maybe String
    , followers : List Follower
    }


type alias Follower =
    { id : GraphQL.Scalar.Id.Id
    , username : String
    }


new : GraphQL.Operation.Operation Data
new =
    GraphQL.Operation.new
        { name = "FetchUser"
        , query = """
            query FetchUser {
                user {
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
            }
        """
        , variables = []
        , decoder =
            GraphQL.Decode.object Data
                |> GraphQL.Decode.field
                    { name = "users"
                    , decoder =
                        GraphQL.Decode.object User
                            |> GraphQL.Decode.field
                                { name = "id"
                                , decoder = GraphQL.Decode.id
                                }
                            |> GraphQL.Decode.field
                                { name = "username"
                                , decoder = GraphQL.Decode.string
                                }
                            |> GraphQL.Decode.field
                                { name = "avatarUrl"
                                , decoder =
                                    GraphQL.Decode.string
                                        |> GraphQL.Decode.maybe
                                }
                            |> GraphQL.Decode.field
                                { name = "followers"
                                , decoder =
                                    GraphQL.Decode.object Follower
                                        |> GraphQL.Decode.field
                                            { name = "id"
                                            , decoder = GraphQL.Decode.id
                                            }
                                        |> GraphQL.Decode.field
                                            { name = "username"
                                            , decoder = GraphQL.Decode.string
                                            }
                                        |> GraphQL.Decode.list
                                }
                    }
        }
