module Api.Enum.Department exposing
    ( Department(..)
    , fromString
    , list
    )


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
