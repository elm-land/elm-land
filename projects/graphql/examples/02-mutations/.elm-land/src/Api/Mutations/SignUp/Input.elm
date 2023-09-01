module Api.Mutations.SignUp.Input exposing 
    ( Input, new
    , email, password, username
    , null
    , toInternalValue
    )

{-|

@docs Input, new
@docs email, password, username
@docs null
@docs toInternalValue

-}

import Dict exposing (Dict)
import GraphQL.Encode



-- INPUT


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input { missing | email : String, password : String }
new =
    Input Dict.empty



-- FIELDS


email : String -> Input { missing | email : String } -> Input missing
email value_ (Input dict_) =
    Input (Dict.insert "email" (GraphQL.Encode.string value_) dict_)


password : String -> Input { missing | password : String } -> Input missing
password value_ (Input dict_) =
    Input (Dict.insert "password" (GraphQL.Encode.string value_) dict_)


username : String -> Input missing -> Input missing
username value_ (Input dict_) =
    Input (Dict.insert "username" (GraphQL.Encode.string value_) dict_)


null : { username : Input missing -> Input missing }
null =
    { username = \(Input dict_) -> Input (Dict.insert "username" GraphQL.Encode.null dict_)
    }



-- USED INTERNALLY


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
