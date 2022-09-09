module Fruit.Color exposing (Color(..), compare, fromString, list, toString, viewBadge)

import Html exposing (..)
import Html.Attributes exposing (class, classList)


type Color
    = Red
    | Yellow
    | Green
    | Blue


list : List Color
list =
    [ Red
    , Yellow
    , Green
    , Blue
    ]


viewBadge : Color -> Html msg
viewBadge color =
    span
        [ class "tag is-light"
        , classList
            [ ( "is-danger", color == Red )
            , ( "is-success", color == Green )
            , ( "is-info", color == Blue )
            , ( "is-warning", color == Yellow )
            ]
        ]
        [ text (toString color) ]


toString : Color -> String
toString color =
    case color of
        Red ->
            "Red"

        Yellow ->
            "Yellow"

        Green ->
            "Green"

        Blue ->
            "Blue"


fromString : String -> Maybe Color
fromString string =
    case string of
        "Red" ->
            Just Red

        "Yellow" ->
            Just Yellow

        "Green" ->
            Just Green

        "Blue" ->
            Just Blue

        _ ->
            Nothing


compare : Color -> Color -> Basics.Order
compare color1 color2 =
    Basics.compare
        (toString color1)
        (toString color2)
