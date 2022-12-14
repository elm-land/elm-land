module Fruit.Column exposing
    ( Column(..)
    , toString, viewSortIcon
    , fromQueryParameter, toQueryParameter
    )

{-|

@docs Column
@docs toString, viewSortIcon
@docs fromQueryParameter, toQueryParameter

-}

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
            "ID"

        Name ->
            "Name"

        Color ->
            "Color"


type alias Sort =
    { column : Column
    , direction : Sort.Direction.Direction
    }


toQueryParameter : Sort -> String
toQueryParameter sort =
    case sort.direction of
        Sort.Direction.Ascending ->
            "asc_" ++ toString sort.column

        Sort.Direction.Descending ->
            "desc_" ++ toString sort.column


fromQueryParameter : String -> Maybe Sort
fromQueryParameter str =
    let
        withDirection : Sort.Direction.Direction -> String -> Maybe Sort
        withDirection direction columnName =
            case columnName of
                "ID" ->
                    Just
                        { column = ID
                        , direction = direction
                        }

                "Name" ->
                    Just
                        { column = Name
                        , direction = direction
                        }

                "Color" ->
                    Just
                        { column = Color
                        , direction = direction
                        }

                _ ->
                    Nothing
    in
    case String.split "_" str of
        "asc" :: columnName :: [] ->
            columnName
                |> withDirection Sort.Direction.Ascending

        "desc" :: columnName :: [] ->
            columnName
                |> withDirection Sort.Direction.Descending

        _ ->
            Nothing


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
