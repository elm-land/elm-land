module Pages.Home_ exposing (page)

import Html exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body =
        [ h1 [] [ text "Hello, SCSS!" ]
        ]
    }
