module Pages.SignIn exposing (page)

import Html exposing (Html)
import View exposing (View)


page : View msg
page =
    { title = "Pages.SignIn"
    , body = [ Html.text "/sign-in" ]
    }