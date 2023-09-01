module Api.Input exposing (UserSignInForm)

{-| This module is here to help make error messages easier to read, and
type annotations a bit easier to understand.

If you are trying to create an input for your query or mutation,
use the `new` function exposed by a `Api.Input.*` module instead.

For example, here's what that looks like for the GraphQL input "UserSignInForm":

    import Api.Input
    import Api.Input.UserSignInForm

    input : Api.Input.UserSignInForm
    input =
        Api.Input.UserSignInForm.new
            |> ...

-}

import Api.Internals.Input


type alias UserSignInForm =
    Api.Internals.Input.UserSignInForm {}
