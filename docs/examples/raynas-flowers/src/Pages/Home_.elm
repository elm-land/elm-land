module Pages.Home_ exposing (page)

import Html exposing (Html)
import Html.Attributes


page : Html msg
page =
    Html.div [ Html.Attributes.class "app" ]
        [ Html.h1 [] [ Html.text "Rayna's Flowers" ]
        , Html.p [] [ Html.text "These flowers are the best!" ]
        ]
