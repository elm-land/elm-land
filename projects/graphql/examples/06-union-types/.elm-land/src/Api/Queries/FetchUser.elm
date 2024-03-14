module Api.Queries.FetchUser exposing 
    ( Data, new
    , UserResult
    )

{-|

@docs Data, new
@docs UserResult

-}

import Api.Queries.FetchUser.UserResult
import GraphQL.Decode
import GraphQL.Operation



-- OUTPUT


type alias Data =
    { currentUser : UserResult
    }


type alias UserResult =
    Api.Queries.FetchUser.UserResult.UserResult



-- OPERATION


new : GraphQL.Operation.Operation Data
new =
    GraphQL.Operation.new
        { name = "FetchUser"
        , query = """
            query FetchUser {
              currentUser {
                __typename # 🌈 Injected by @elm-land/graphql ✨
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
        , variables = []
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "currentUser"
            , decoder = 
                GraphQL.Decode.union
                    [ GraphQL.Decode.variant
                          { typename = "User"
                          , onVariant = Api.Queries.FetchUser.UserResult.On_User
                          , decoder = 
                              GraphQL.Decode.object Api.Queries.FetchUser.UserResult.User
                                  |> GraphQL.Decode.field
                                      { name = "id"
                                      , decoder = GraphQL.Decode.id
                                      }
                                  |> GraphQL.Decode.field
                                      { name = "name"
                                      , decoder = GraphQL.Decode.string
                                      }
                                  |> GraphQL.Decode.field
                                      { name = "avatarUrl"
                                      , decoder = 
                                          GraphQL.Decode.string
                                              |> GraphQL.Decode.maybe
                                      }
                          }
                    , GraphQL.Decode.variant
                          { typename = "NotSignedIn"
                          , onVariant = Api.Queries.FetchUser.UserResult.On_NotSignedIn
                          , decoder = 
                              GraphQL.Decode.object Api.Queries.FetchUser.UserResult.NotSignedIn
                                  |> GraphQL.Decode.field
                                      { name = "message"
                                      , decoder = GraphQL.Decode.string
                                      }
                          }
                    ]
            }
