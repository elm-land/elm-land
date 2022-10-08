module GraphQL.Scalar.ID exposing
    ( ID
    , fromString, toString
    , decoder
    )

{-|

@docs ID
@docs fromString, toString

**Used by @elm-land/graphql:**

@docs decoder, encode

-}

import Json.Decode
import Json.Encode


type ID
    = ID String


fromString : String -> ID
fromString string =
    ID string


toString : ID -> String
toString (ID string) =
    string



-- Used by @elm-land/graphql


decoder : Json.Decode.Decoder ID
decoder =
    Json.Decode.map ID Json.Decode.string


encode : ID -> Json.Encode.Value
encode (ID string) =
    Json.Encode.string string
