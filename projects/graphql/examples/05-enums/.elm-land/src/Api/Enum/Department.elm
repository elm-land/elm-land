module Api.Enum.Department exposing 
    ( Department(..)
    , list, fromString
    , decoder, encode
    )

{-|

@docs Department
@docs list, fromString
@docs decoder, encode

-}

import GraphQL.Decode
import GraphQL.Encode


type Department
    = PRODUCT
    | DESIGN
    | ENGINEERING
    | MARKETING
    | SALES


list : List Department
list =
    [ PRODUCT
    , DESIGN
    , ENGINEERING
    , MARKETING
    , SALES
    ]


fromString : String -> Maybe Department
fromString str =
    case str of
        "PRODUCT" ->
            Just PRODUCT

        "DESIGN" ->
            Just DESIGN

        "ENGINEERING" ->
            Just ENGINEERING

        "MARKETING" ->
            Just MARKETING

        "SALES" ->
            Just SALES

        _ ->
            Nothing



-- USED INTERNALLY


toString : Department -> String
toString enum =
    case enum of
        PRODUCT ->
            "PRODUCT"

        DESIGN ->
            "DESIGN"

        ENGINEERING ->
            "ENGINEERING"

        MARKETING ->
            "MARKETING"

        SALES ->
            "SALES"


encode : Department -> GraphQL.Encode.Value
encode enum =
    GraphQL.Encode.enum
        { toString = toString
        , value = enum
        }


decoder : GraphQL.Decode.Decoder Department
decoder =
    list
        |> List.map (\enum -> ( toString enum, enum ))
        |> GraphQL.Decode.enum
