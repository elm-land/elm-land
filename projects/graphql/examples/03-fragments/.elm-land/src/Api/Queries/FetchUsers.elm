module Api.Queries.FetchUsers exposing 
    ( Data, new
    , Follower, User
    )

{-|

@docs Data, new
@docs Follower, User

-}

import GraphQL.Decode
import GraphQL.Operation
import GraphQL.Scalar.Id



-- OUTPUT


type alias Data =
    { user : Maybe User
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



-- OPERATION


new : GraphQL.Operation.Operation Data
new =
    GraphQL.Operation.new
        { name = "FetchUsers"
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
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "user"
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
                    |> GraphQL.Decode.maybe
            }
