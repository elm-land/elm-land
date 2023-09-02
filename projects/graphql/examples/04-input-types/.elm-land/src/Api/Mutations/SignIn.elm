module Api.Mutations.SignIn exposing 
    ( Input, Data, new
    , User
    )

{-|

@docs Input, Data, new
@docs User

-}

import Api.Mutations.SignIn.Input
import GraphQL.Decode
import GraphQL.Operation
import GraphQL.Scalar.Id



-- INPUT


type alias Input =
    Api.Mutations.SignIn.Input.Input {}



-- OUTPUT


type alias Data =
    { signIn : Maybe User
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
        { name = "SignIn"
        , query = """
            mutation SignIn($form: UserSignInForm!) {
              signIn(form: $form) {
                id
                email 
                avatarUrl
              }
            }
          """
        , variables = Api.Mutations.SignIn.Input.toInternalValue input
        , decoder = decoder
        }


decoder : GraphQL.Decode.Decoder Data
decoder =
    GraphQL.Decode.object Data
        |> GraphQL.Decode.field
            { name = "signIn"
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
