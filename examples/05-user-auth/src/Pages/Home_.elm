module Pages.Home_ exposing (page)

import Html exposing (Html)
import Html.Attributes as Attr
import Route.Path
import View exposing (View)


page : View msg
page =
    { title = "Dashboard"
    , body = [ viewPage ]
    }


viewPage : Html msg
viewPage =
    Html.section [ Attr.class "hero is-link" ]
        [ Html.div [ Attr.class "hero-body" ]
            [ Html.h1 [ Attr.class "title" ] [ Html.text "Dashboard" ]
            , Html.h2 [ Attr.class "subtitle" ]
                [ Html.text "With a link back to the "
                , Html.a
                    [ Attr.class "is-underlined", Attr.href (Route.Path.toString Route.Path.SignIn) ]
                    [ Html.text "sign in page" ]
                , Html.text "!"
                ]
            ]
        ]
