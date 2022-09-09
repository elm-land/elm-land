module Fruit.Color exposing (Color(..), compare, list, toString, viewBadge)

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


compare : Color -> Color -> Basics.Order
compare color1 color2 =
    Basics.compare
        (toString color1)
        (toString color2)
