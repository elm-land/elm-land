module Api.Mutations.SignIn.Input exposing
    ( Input, new
    , form
    , toInternalValue
    )

{-|

@docs Input, new
@docs form

@docs toInternalValue

-}

import Api.Input
import Api.Internals.Input
import Dict exposing (Dict)
import GraphQL.Encode


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | form : Api.Input.UserSignInForm }
new =
    Input Dict.empty


form :
    Api.Input.UserSignInForm
    -> Input { missing | form : Api.Input.UserSignInForm }
    -> Input missing
form (Api.Internals.Input.UserSignInForm value_) (Input input_) =
    Input (Dict.insert "form" (GraphQL.Encode.input (Dict.toList value_)) input_)


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input input_) =
    Dict.toList input_
