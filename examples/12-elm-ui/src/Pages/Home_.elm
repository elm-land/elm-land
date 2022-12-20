module Pages.Home_ exposing (page)

import Element
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , attributes = []
    , element =
        Element.el [ Element.centerX, Element.centerY ]
            (Element.text "Hello, Elm UI! ✨")
    }
