module Layouts.Navbar exposing (layout)

import Html exposing (Html)
import Html.Attributes as Attr
import Route.Path
import View exposing (View)


layout : { page : View msg } -> View msg
layout { page } =
    { title = page.title
    , body =
        [ Html.div [ Attr.class "container p-4" ] [ viewNavbar ]
        , Html.div [ Attr.class "page" ] page.body
        ]
    }


viewNavbar : Html msg
viewNavbar =
    Html.nav [ Attr.class "level is-mobile" ]
        [ Html.div [ Attr.class "level-left pr-6" ]
            [ Html.p [ Attr.class "level-item" ]
                [ Html.a [ Attr.href (Route.Path.toString Route.Path.Home_) ] [ Html.text "Dashboard" ]
                ]
            , Html.p [ Attr.class "level-item" ]
                [ Html.a [ Attr.href (Route.Path.toString Route.Path.Settings) ] [ Html.text "Settings" ]
                ]
            , Html.p [ Attr.class "level-item" ]
                [ Html.a [ Attr.href (Route.Path.toString Route.Path.Profile) ] [ Html.text "Profile" ]
                ]
            ]
        ]
