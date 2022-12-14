module Sort.Direction exposing (Direction(..), flip)


type Direction
    = Ascending
    | Descending


flip : Direction -> Direction
flip direction =
    case direction of
        Ascending ->
            Descending

        Descending ->
            Ascending
