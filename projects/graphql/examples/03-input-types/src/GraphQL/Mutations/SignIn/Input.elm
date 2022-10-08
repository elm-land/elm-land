module GraphQL.Mutations.SignIn.Input exposing
    ( Input, new
    , form
    , null
    , toInternalValue
    )

{-|

@docs Input, new

@docs form
@docs null

@docs toInternalValue

-}

import GraphQL.Input
import GraphQL.Internals.Http
import GraphQL.Internals.Input
import Json.Encode


type Input missing
    = Input GraphQL.Internals.Http.Input


new : Input { missing | form : GraphQL.Input.UserSignInForm }
new =
    Input GraphQL.Internals.Http.input


form :
    GraphQL.Input.UserSignInForm
    -> Input { missing | form : GraphQL.Input.UserSignInForm }
    -> Input missing
form (GraphQL.Internals.Input.UserSignInForm value_) (Input input_) =
    Input (GraphQL.Internals.Http.with "form" (GraphQL.Internals.Http.encode value_) input_)


null : {}
null =
    {}


toInternalValue : Input {} -> GraphQL.Internals.Http.Input
toInternalValue (Input input_) =
    input_
