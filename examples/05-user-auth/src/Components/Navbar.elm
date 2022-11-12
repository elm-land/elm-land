module Components.Navbar exposing (view)

import Html exposing (Html)
import Html.Attributes as Attr
import Route.Path


view : { page : Html msg } -> Html msg
view options =
    Html.div [ Attr.class "layout" ]
        [ Html.div [ Attr.class "container p-4" ] [ viewNavbar ]
        , Html.div [ Attr.class "page" ] [ options.page ]
        ]


viewNavbar : Html msg
viewNavbar =
    Html.nav [ Attr.class "level is-mobile" ]
        [ Html.div [ Attr.class "level-left pr-6" ]
            [ Html.p [ Attr.class "level-item" ]
                [ Html.a [ Route.Path.href Route.Path.Home_ ] [ Html.text "Dashboard" ]
                ]
            , Html.p [ Attr.class "level-item" ]
                [ Html.a [ Route.Path.href Route.Path.Settings ] [ Html.text "Settings" ]
                ]
            , Html.p [ Attr.class "level-item" ]
                [ Html.a [ Route.Path.href Route.Path.Profile ] [ Html.text "Profile" ]
                ]
            ]
        ]
