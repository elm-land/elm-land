module Pages.Settings.Account exposing (page)

import Components.Sidebar
import Html exposing (Html)
import View exposing (View)


page : View msg
page =
    { title = "Pages.Settings.Account"
    , body =
        [ Components.Sidebar.view
            { page = Html.text "/settings/account"
            }
        ]
    }
