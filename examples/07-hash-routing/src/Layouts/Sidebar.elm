module Layouts.Sidebar exposing (layout)

import Dict
import Html exposing (Html)
import Html.Attributes as Attr
import Route
import Route.Path exposing (Path(..))
import View exposing (View)


layout : { page : View msg } -> View msg
layout { page } =
    { title = page.title
    , body =
        [ Html.div [ Attr.class "layout" ]
            [ viewSidebar
            , Html.div [ Attr.class "page" ] page.body
            ]
        ]
    }


viewSidebar : Html msg
viewSidebar =
    Html.aside [ Attr.class "sidebar" ]
        [ Html.a [ Route.Path.href Home_ ] [ Html.text "Home" ]
        , Html.a [ Route.Path.href Faq ] [ Html.text "FAQ" ]
        , Html.a [ Route.Path.href About ] [ Html.text "About" ]
        , Html.a
            [ Route.href
                { path = Users__UserId_ { userId = "4" }
                , query = Dict.fromList [ ( "foo", "bar" ) ]
                , hash = Just "yoDawg"
                }
            ]
            [ Html.text "User4" ]
        ]
