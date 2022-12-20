module Components.Sidebar exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr


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
        [ Html.a [ Attr.href "/" ] [ Html.text "Home" ]
        , Html.a [ Attr.href "/profile/me" ] [ Html.text "Profile" ]
        , Html.a [ Attr.href "/settings/account" ] [ Html.text "Settings" ]
        , Html.hr [] []
        , Html.a [ Attr.href "/blog/hello" ] [ Html.text "/blog/hello" ]
        , Html.a [ Attr.href "/blog/elm/land" ] [ Html.text "/blog/elm/land" ]
        , Html.a [ Attr.href "/blog/elm/land/ui" ] [ Html.text "/blog/elm/land/ui" ]
        ]
