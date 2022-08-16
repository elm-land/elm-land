module Pages.Profile.Username_ exposing (page)

import Html exposing (Html)
import Layout exposing (Layout)
import View exposing (View)


layout : Layout
layout =
    Layout.Sidebar


page : { username : String } -> View msg
page params =
    { title = "Pages.Profile.Username_"
    , body = [ Html.text ("/profile/" ++ params.username) ]
    }
