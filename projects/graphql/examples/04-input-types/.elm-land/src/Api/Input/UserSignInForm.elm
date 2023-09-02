module Api.Input.UserSignInForm exposing 
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
    Api.Internals.Input.UserSignInForm missing


new : Input { missing | email : String, password : String }
new =
    Api.Internals.Input.UserSignInForm Dict.empty



-- FIELDS


email : String -> Input { missing | email : String } -> Input missing
email value_ (Api.Internals.Input.UserSignInForm dict_) =
    Api.Internals.Input.UserSignInForm (Dict.insert "email" (GraphQL.Encode.string value_) dict_)


password : String -> Input { missing | password : String } -> Input missing
password value_ (Api.Internals.Input.UserSignInForm dict_) =
    Api.Internals.Input.UserSignInForm (Dict.insert "password" (GraphQL.Encode.string value_) dict_)
