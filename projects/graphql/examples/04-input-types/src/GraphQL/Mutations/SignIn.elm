module GraphQL.Mutations.SignIn exposing
    ( Input, Data, new
    , User
    )

{-|

@docs Input, Data, new

@docs User

-}

import GraphQL
import GraphQL.Internals.Http
import GraphQL.Mutations.SignIn.Input
import GraphQL.Scalar
import GraphQL.Scalar.ID


type alias Data =
    { signIn : Maybe User
    }


type alias User =
    { id : GraphQL.Scalar.ID
    , email : String
    , avatarUrl : Maybe String
    }


type alias Input =
    GraphQL.Mutations.SignIn.Input.Input {}


new : Input -> GraphQL.Mutation Data
new input =
    GraphQL.Internals.Http.operation
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
        , variables = Just (GraphQL.Mutations.SignIn.Input.toInternalValue input)
        , decoder =
            GraphQL.Internals.Http.object Data
                |> GraphQL.Internals.Http.field "signIn"
                    { wrapper = GraphQL.Internals.Http.maybe
                    , decoder =
                        GraphQL.Internals.Http.object User
                            |> GraphQL.Internals.Http.field "id"
                                { wrapper = GraphQL.Internals.Http.none
                                , decoder = GraphQL.Internals.Http.scalars.custom GraphQL.Scalar.ID.decoder
                                }
                            |> GraphQL.Internals.Http.field "email"
                                { wrapper = GraphQL.Internals.Http.none
                                , decoder = GraphQL.Internals.Http.scalars.string
                                }
                            |> GraphQL.Internals.Http.field "avatarUrl"
                                { wrapper = GraphQL.Internals.Http.maybe
                                , decoder = GraphQL.Internals.Http.scalars.string
                                }
                    }
        }
