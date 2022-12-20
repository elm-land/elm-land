module Components.Sidebar exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Route.Path


view : { page : Html msg } -> Html msg
view options =
    Html.div
        [ Attr.class "layout" ]
        [ viewSidebar
        , Html.div [ Attr.class "page" ] [ options.page ]
        ]


viewSidebar : Html msg
viewSidebar =
    Html.aside [ Attr.class "sidebar" ]
        [ Html.a [ Route.Path.href Route.Path.Home_ ] [ Html.text "Home" ]
        , Html.a [ Route.Path.href (Route.Path.Profile_Username_ { username = "me" }) ] [ Html.text "Profile" ]
        , Html.a [ Route.Path.href Route.Path.Settings_Account ] [ Html.text "Settings" ]
        ]
