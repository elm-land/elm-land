module GraphQL.Input exposing (UserSignInForm)

{-| This module is here to help make error messages easier to read, and
type annotations a bit easier to understand.

If you are trying to create an input for your query or mutation,
use the `new` function exposed by a `GraphQL.Input.*` module instead.

For example, here's what that looks like for the GraphQL input "UserSignInForm":

    import GraphQL.Input
    import GraphQL.Input.UserSignInForm

    input : GraphQL.Input.UserSignInForm
    input =
        GraphQL.Input.UserSignInForm.new
            |> ...

-}

import GraphQL.Internals.Input


type alias UserSignInForm =
    GraphQL.Internals.Input.UserSignInForm {}
