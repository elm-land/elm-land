module Api.Mutations.SignUp exposing 
    ( Input, Data, new
    , User
    )

{-|

@docs Input, Data, new
@docs User

-}

import Api.Mutations.SignUp.Input
import GraphQL.Decode
import GraphQL.Operation
import GraphQL.Scalar.Id



-- INPUT


type alias Input =
    Api.Mutations.SignUp.Input.Input {}



-- OUTPUT


type alias Data =
    { signUp : Maybe User
    }


type alias User =
    { id : GraphQL.Scalar.Id.Id
    , email : String
    , avatarUrl : Maybe String
    }



-- OPERATION


new : Input -> GraphQL.Operation.Operation Data
new input =
    GraphQL.Operation.new
        { name = "SignUp"
        , query = """
            mutation SignUp(
              $email: String!
              $password: String!
              $username: String
            ) {
              signUp(email: $email, password: $password, username: $username) {
                id
                email
                avatarUrl
              }
            }
          """
        , variables = Api.Mutations.SignUp.Input.toInternalValue input
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "signUp"
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
