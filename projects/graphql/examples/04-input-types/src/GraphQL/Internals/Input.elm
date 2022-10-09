module GraphQL.Internals.Input exposing (UserSignInForm(..))

{-| **Warning: Internal use only**

To prevent circular dependencies, Elm Land needs to generate
all inputs in one file.

If you are trying to create an input for your query or mutation,
DO NOT use this module, use the `new` function exposed by a
`GraphQL.Input.*` module instead.

For example, here's what that looks like for the GraphQL input "UserSignInForm":

    import GraphQL.Input
    import GraphQL.Input.UserSignInForm

    input : GraphQL.Input.UserSignInForm
    input =
        GraphQL.Input.UserSignInForm.new
            ...

-}

import GraphQL.Internals.Http


type UserSignInForm missing
    = UserSignInForm GraphQL.Internals.Http.Input
