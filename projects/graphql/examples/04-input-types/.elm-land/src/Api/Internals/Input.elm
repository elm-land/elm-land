module Api.Internals.Input exposing (UserSignInForm(..))

{-| **Warning: Internal use only**

To prevent circular dependencies, Elm Land needs to generate
all inputs in one file.

If you are trying to create an input for your query or mutation,
DO NOT use this module, use the `new` function exposed by a
`Api.Input.*` module instead.

For example, here's what that looks like for the GraphQL input "UserSignInForm":

    import Api.Input
    import Api.Input.UserSignInForm

    input : Api.Input.UserSignInForm
    input =
        Api.Input.UserSignInForm.new
            ...

-}

import Dict exposing (Dict)
import GraphQL.Encode


type UserSignInForm missing
    = UserSignInForm (Dict String GraphQL.Encode.Value)
