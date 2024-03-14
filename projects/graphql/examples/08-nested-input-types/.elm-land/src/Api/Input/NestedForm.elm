module Api.Input.NestedForm exposing 
    ( Input, new
    , email, password
    )

{-|

@docs Input, new
@docs email, password

-}

import Api.Internals.Input
import Dict exposing (Dict)
import GraphQL.Encode



-- INPUT


type alias Input missing =
    Api.Internals.Input.NestedForm missing


new : Input { missing | email : String, password : String }
new =
    Api.Internals.Input.NestedForm Dict.empty



-- FIELDS


email : String -> Input { missing | email : String } -> Input missing
email value_ (Api.Internals.Input.NestedForm dict_) =
    Api.Internals.Input.NestedForm (Dict.insert "email" (GraphQL.Encode.string value_) dict_)


password : String -> Input { missing | password : String } -> Input missing
password value_ (Api.Internals.Input.NestedForm dict_) =
    Api.Internals.Input.NestedForm (Dict.insert "password" (GraphQL.Encode.string value_) dict_)
