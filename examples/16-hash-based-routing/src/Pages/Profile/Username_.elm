module Pages.Profile.Username_ exposing (page)

import Components.Sidebar
import Html exposing (Html)
import View exposing (View)


page : { username : String } -> View msg
page params =
    { title = "Pages.Profile.Username_"
    , body =
        [ Components.Sidebar.view
            { page = Html.text ("/profile/" ++ params.username)
            }
        ]
    }
