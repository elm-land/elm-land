module Api.Mutations.SignUp.Input exposing
    ( Input, new
    , email, password, name
    , null
    , toInternalValue
    )

{-|

@docs Input, new

@docs email, password, name
@docs null

@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode
import Json.Encode


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | email : String, password : String }
new =
    Input Dict.empty


email :
    String
    -> Input { missing | email : String }
    -> Input missing
email value (Input dict_) =
    Input (Dict.insert "email" (GraphQL.Encode.string value) dict_)


password :
    String
    -> Input { missing | password : String }
    -> Input missing
password value (Input dict_) =
    Input (Dict.insert "password" (GraphQL.Encode.string value) dict_)


name :
    String
    -> Input missing
    -> Input missing
name value (Input dict_) =
    Input (Dict.insert "name" (GraphQL.Encode.string value) dict_)


null :
    { name : Input missing -> Input missing
    }
null =
    { name = \(Input dict_) -> Input (Dict.insert "name" GraphQL.Encode.null dict_)
    }


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
