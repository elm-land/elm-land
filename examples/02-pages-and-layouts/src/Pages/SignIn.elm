module Pages.SignIn exposing (page)

import Components.Sidebar
import Html exposing (Html)
import View exposing (View)


page : View msg
page =
    { title = "Pages.SignIn"
    , body =
        [ Components.Sidebar.view
            { page = Html.text "/sign-in"
            }
        ]
    }
