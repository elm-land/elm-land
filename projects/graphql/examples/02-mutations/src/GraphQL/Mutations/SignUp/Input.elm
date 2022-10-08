module GraphQL.Mutations.SignUp.Input exposing
    ( Input, new
    , email, password, avatarUrl
    , null
    , toInternalValue
    )

{-|

@docs Input, new

@docs email, password, avatarUrl
@docs null

@docs toInternalValue

-}

import GraphQL.Internals.Http
import Json.Encode


type Input missing
    = Input GraphQL.Internals.Http.Input


new : Input { missing | email : String, password : String }
new =
    Input GraphQL.Internals.Http.input


email :
    String
    -> Input { missing | email : String }
    -> Input missing
email value (Input input_) =
    Input (GraphQL.Internals.Http.with "email" (Json.Encode.string value) input_)


password :
    String
    -> Input { missing | password : String }
    -> Input missing
password value (Input input_) =
    Input (GraphQL.Internals.Http.with "password" (Json.Encode.string value) input_)


avatarUrl :
    String
    -> Input missing
    -> Input missing
avatarUrl value (Input input_) =
    Input (GraphQL.Internals.Http.with "avatarUrl" (Json.Encode.string value) input_)


null :
    { avatarUrl : Input missing -> Input missing
    }
null =
    { avatarUrl = \(Input input_) -> Input (GraphQL.Internals.Http.null "avatarUrl" input_)
    }


toInternalValue : Input {} -> GraphQL.Internals.Http.Input
toInternalValue (Input input_) =
    input_
