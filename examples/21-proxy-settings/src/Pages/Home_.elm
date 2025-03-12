module Pages.Home_ exposing (page)

import Html
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body = [ Html.text "Hello, world!" ]
    }
