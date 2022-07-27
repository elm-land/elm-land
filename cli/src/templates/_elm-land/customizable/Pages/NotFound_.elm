module Pages.NotFound_ exposing (page)

import Html exposing (Html)
import View exposing (View)


page : View msg
page =
    { title = "404"
    , body = [ Html.text "Page not found..." ]
    }