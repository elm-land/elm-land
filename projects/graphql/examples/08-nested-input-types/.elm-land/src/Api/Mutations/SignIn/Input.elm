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



-- INPUT


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | form : Api.Input.UserSignInForm }
new =
    Input Dict.empty



-- FIELDS


form : Api.Input.UserSignInForm -> Input { missing | form : Api.Input.UserSignInForm } -> Input missing
form (Api.Internals.Input.UserSignInForm value_) (Input dict_) =
    Input (Dict.insert "form" ((Dict.toList >> GraphQL.Encode.input) value_) dict_)



-- USED INTERNALLY


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
