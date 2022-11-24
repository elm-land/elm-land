module Pages.Home_ exposing (page)

import Components.Sidebar
import Html
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body =
        [ Components.Sidebar.view
            { page = Html.text "Hello, world!"
            }
        ]
    }
