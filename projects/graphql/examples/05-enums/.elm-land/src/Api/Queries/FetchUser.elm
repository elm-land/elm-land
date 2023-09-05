module Api.Queries.FetchUser exposing 
    ( Data, new
    , User
    )

{-|

@docs Data, new
@docs User

-}

import Api.Enum.Department
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
    , department : Api.Enum.Department.Department
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
                department 
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
                        { name = "department"
                        , decoder = Api.Enum.Department.decoder
                        }
                    |> GraphQL.Decode.maybe
            }
