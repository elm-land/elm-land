module Pages.User_ exposing (page)

import Html exposing (..)
import Route.Path
import View exposing (View)


page : { user : String } -> View msg
page params =
    { title = "@" ++ params.user ++ " | Users"
    , body =
        [ h1 [] [ text ("🧑\u{200D}💻 @" ++ params.user) ]
        , p [] [ text "Hello from `src/Pages/User_.elm 👋" ]
        , a [ Route.Path.href Route.Path.Home_ ] [ text "Back to homepage" ]
        ]
    }
