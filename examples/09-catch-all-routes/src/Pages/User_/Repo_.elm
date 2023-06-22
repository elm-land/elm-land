module Pages.User_.Repo_ exposing (page)

import Html exposing (..)
import Route.Path
import View exposing (View)


page : { user : String, repo : String } -> View msg
page params =
    { title = "@" ++ params.user ++ "/" ++ params.repo ++ " | Repos"
    , body =
        [ h1 [] [ text ("📦 @" ++ params.user ++ "/" ++ params.repo) ]
        , p [] [ text "Hello from `src/Pages/User_/Repo_.elm 👋" ]
        , a [ Route.Path.href Route.Path.Home_ ] [ text "Back to homepage" ]
        ]
    }
