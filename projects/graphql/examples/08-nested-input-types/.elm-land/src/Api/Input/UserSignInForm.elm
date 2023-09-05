module Api.Input.UserSignInForm exposing 
    ( Input, new
    , form
    )

{-|

@docs Input, new
@docs form

-}

import Api.Input
import Api.Internals.Input
import Api.Internals.Input
import Dict exposing (Dict)
import GraphQL.Encode



-- INPUT


type alias Input missing =
    Api.Internals.Input.UserSignInForm missing


new : Input { missing | form : Api.Input.NestedForm }
new =
    Api.Internals.Input.UserSignInForm Dict.empty



-- FIELDS


form : Api.Input.NestedForm -> Input { missing | form : Api.Input.NestedForm } -> Input missing
form (Api.Internals.Input.NestedForm value_) (Api.Internals.Input.UserSignInForm dict_) =
    Api.Internals.Input.UserSignInForm (Dict.insert "form" ((Dict.toList >> GraphQL.Encode.input) value_) dict_)
