module Api.Queries.FetchUser exposing
    ( Data, new
    , User
    )

{-|

@docs Data, new
@docs User

-}

import GraphQL.Decode
import GraphQL.Operation
import GraphQL.Scalar.Id



-- OUTPUT


type alias Data =
    { me : Maybe User
    }


type alias User =
    { id : GraphQL.Scalar.Id.Id
    , email : String
    , avatarUrl : Maybe String
    }



-- OPERATION


new : GraphQL.Operation.Operation Data
new =
    GraphQL.Operation.new
        { name = "FetchUser"
        , query = """
            query FetchUser {
              me {
                id 
                email 
                avatarUrl 
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
            { name = "me"
            , decoder =
                GraphQL.Decode.object User
                    |> GraphQL.Decode.field
                        { name = "id"
                        , decoder = GraphQL.Decode.id
                        }
                    |> GraphQL.Decode.field
                        { name = "email"
                        , decoder = GraphQL.Decode.string
                        }
                    |> GraphQL.Decode.field
                        { name = "avatarUrl"
                        , decoder =
                            GraphQL.Decode.string
                                |> GraphQL.Decode.maybe
                        }
                    |> GraphQL.Decode.maybe
            }
