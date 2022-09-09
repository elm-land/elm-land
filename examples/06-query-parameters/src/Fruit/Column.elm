module Fruit.Column exposing (Column(..), toString, viewSortIcon)

import Html exposing (..)
import Html.Attributes exposing (class)
import Sort.Direction exposing (Direction(..))


type Column
    = ID
    | Name
    | Color


toString : Column -> String
toString column =
    case column of
        ID ->
            "Fruit ID"

        Name ->
            "Name"

        Color ->
            "Color"


toColumnDataType : Column -> ColumnSortValueType
toColumnDataType column =
    case column of
        ID ->
            NumericSortValue

        Name ->
            AlphaSortValue

        Color ->
            AlphaSortValue


type ColumnSortValueType
    = NumericSortValue
    | AlphaSortValue


viewSortIcon :
    { column : Column
    , direction : Sort.Direction.Direction
    }
    -> Html msg
viewSortIcon sort =
    case ( toColumnDataType sort.column, sort.direction ) of
        ( NumericSortValue, Sort.Direction.Ascending ) ->
            i [ class "fas fa-sort-numeric-down" ] []

        ( NumericSortValue, Sort.Direction.Descending ) ->
            i [ class "fas fa-sort-numeric-down-alt" ] []

        ( AlphaSortValue, Sort.Direction.Ascending ) ->
            i [ class "fas fa-sort-alpha-down" ] []

        ( AlphaSortValue, Sort.Direction.Descending ) ->
            i [ class "fas fa-sort-alpha-down-alt" ] []
