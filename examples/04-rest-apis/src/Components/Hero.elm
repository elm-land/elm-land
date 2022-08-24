module Components.Hero exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (class)


view : { title : String, subtitle : String } -> Html msg
view options =
    Html.div [ class "hero is-danger py-6 has-text-centered" ]
        [ Html.h1 [ class "title is-1" ] [ Html.text options.title ]
        , Html.h2 [ class "subtitle is-4" ] [ Html.text options.subtitle ]
        ]
