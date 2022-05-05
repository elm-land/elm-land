module Pages.Profile.Id_ exposing (page)

import Html exposing (Html)


page : { id : String } -> Html msg
page params =
    Html.text ("Profile for: " ++ params.id)
