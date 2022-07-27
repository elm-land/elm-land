module View exposing (View, map, toBrowserDocument)

import Browser
import Html


type alias View msg =
    Browser.Document msg


toBrowserDocument : View msg -> Browser.Document msg
toBrowserDocument view =
    view


map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn view =
    { title = view.title
    , body = List.map (Html.map fn) view.body
    }
