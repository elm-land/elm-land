module Api.Queries.FetchUser exposing 
    ( Input, Data, new
    , User
    )

{-|

@docs Input, Data, new
@docs User

-}

import Api.Queries.FetchUser.Input
import GraphQL.Decode
import GraphQL.Operation
import GraphQL.Scalar.Id



-- INPUT


type alias Input =
    Api.Queries.FetchUser.Input.Input {}



-- OUTPUT


type alias Data =
    { findUser : Maybe User
    }


type alias User =
    { id : GraphQL.Scalar.Id.Id
    , email : String
    }



-- OPERATION


new : Input -> GraphQL.Operation.Operation Data
new input =
    GraphQL.Operation.new
        { name = "FetchUser"
        , query = """
            query FetchUser($department: Department) {
              findUser(department: $department) {
                id 
                email 
              }
            }
          """
        , variables = Api.Queries.FetchUser.Input.toInternalValue input
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "findUser"
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
                    |> GraphQL.Decode.maybe
            }
