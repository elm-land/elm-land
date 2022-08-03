module Pages.Home_ exposing (page)

import Auth
import Html exposing (Html)
import Html.Attributes as Attr
import Route.Path
import View exposing (View)


page : Auth.User -> View msg
page user =
    { title = "Dashboard"
    , body = [ viewPage user ]
    }


viewPage : Auth.User -> Html msg
viewPage user =
    Html.section [ Attr.class "hero is-link" ]
        [ Html.div [ Attr.class "hero-body has-text-centered" ]
            [ Html.h1 [ Attr.class "title" ] [ Html.text "Dashboard" ]
            , Html.h2 [ Attr.class "subtitle" ]
                [ Html.text ("Welcome back, " ++ user.name ++ "!")
                ]
            , Html.a
                [ Attr.class "link is-underlined"
                , Attr.href (Route.Path.toString Route.Path.SignIn)
                ]
                [ Html.text "Back to sign in page" ]

            -- , Html.a [ Attr.class "button" ] [ Html.text "Sign out" ]
            ]
        ]
