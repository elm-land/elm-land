module Pages.Settings.Account exposing (page)

import Html exposing (Html)
import Layout exposing (Layout)
import View exposing (View)


layout : Layout
layout =
    Layout.Sidebar


page : View msg
page =
    { title = "Pages.Settings.Account"
    , body = [ Html.text "/settings/account" ]
    }
