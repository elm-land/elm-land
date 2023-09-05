module Api.Queries.FetchUser.Input exposing 
    ( Input, new
    , department
    , null
    , toInternalValue
    )

{-|

@docs Input, new
@docs department
@docs null
@docs toInternalValue

-}

import Api.Enum.Department
import Dict exposing (Dict)
import GraphQL.Encode



-- INPUT


type Input missing
    = Input (Dict String GraphQL.Encode.Value)


new : Input {}
new =
    Input Dict.empty



-- FIELDS


department : Api.Enum.Department.Department -> Input missing -> Input missing
department value_ (Input dict_) =
    Input (Dict.insert "department" (Api.Enum.Department.encode value_) dict_)


null : { department : Input missing -> Input missing }
null =
    { department = \(Input dict_) -> Input (Dict.insert "department" GraphQL.Encode.null dict_)
    }



-- USED INTERNALLY


toInternalValue : Input {} -> List ( String, GraphQL.Encode.Value )
toInternalValue (Input dict_) =
    Dict.toList dict_
