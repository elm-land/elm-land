module GraphQL.Input.UserSignInForm exposing
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

import GraphQL.Internals.Http
import GraphQL.Internals.Input
import Json.Encode


type alias UserSignInForm missing =
    GraphQL.Internals.Input.UserSignInForm missing


new : UserSignInForm { missing | email : String, password : String }
new =
    GraphQL.Internals.Input.UserSignInForm GraphQL.Internals.Http.input


email :
    String
    -> UserSignInForm { missing | email : String }
    -> UserSignInForm missing
email value (GraphQL.Internals.Input.UserSignInForm input_) =
    GraphQL.Internals.Input.UserSignInForm (GraphQL.Internals.Http.with "email" (Json.Encode.string value) input_)


password :
    String
    -> UserSignInForm { missing | password : String }
    -> UserSignInForm missing
password value (GraphQL.Internals.Input.UserSignInForm input_) =
    GraphQL.Internals.Input.UserSignInForm (GraphQL.Internals.Http.with "password" (Json.Encode.string value) input_)


null : {}
null =
    {}
