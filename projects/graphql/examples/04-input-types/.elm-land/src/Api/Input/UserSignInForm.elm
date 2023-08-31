module Api.Input.UserSignInForm exposing
    ( UserSignInForm, new
    , email, password
    , null
    )

{-|

@docs UserSignInForm, new
@docs email, password
@docs null

@docs toInternalValue

-}

import Api.Internals.Input
import Dict exposing (Dict)
import GraphQL.Encode


type alias UserSignInForm missing =
    Api.Internals.Input.UserSignInForm missing


new : UserSignInForm { missing | email : String, password : String }
new =
    Api.Internals.Input.UserSignInForm Dict.empty


email :
    String
    -> UserSignInForm { missing | email : String }
    -> UserSignInForm missing
email value (Api.Internals.Input.UserSignInForm input_) =
    Api.Internals.Input.UserSignInForm (Dict.insert "email" (GraphQL.Encode.string value) input_)


password :
    String
    -> UserSignInForm { missing | password : String }
    -> UserSignInForm missing
password value (Api.Internals.Input.UserSignInForm input_) =
    Api.Internals.Input.UserSignInForm (Dict.insert "password" (GraphQL.Encode.string value) input_)


null : {}
null =
    {}
