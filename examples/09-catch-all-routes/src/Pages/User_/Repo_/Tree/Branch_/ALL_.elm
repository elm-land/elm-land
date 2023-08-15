module Pages.User_.Repo_.Tree.Branch_.ALL_ exposing (page)

import Html exposing (..)
import Route.Path
import View exposing (View)


page :
    { user : String
    , repo : String
    , branch : String
    , all_ : List String
    }
    -> View msg
page params =
    { title = "@" ++ params.user ++ "/" ++ params.repo ++ " | File Explorer"
    , body =
        [ h1 [] [ text ("🗃 ~/" ++ String.join "/" params.all_) ]
        , p [] [ text "Hello from `src/Pages/User_/Repo_/Tree/Branch_/ALL_.elm 👋" ]
        , a [ Route.Path.href Route.Path.Home_ ] [ text "Back to homepage" ]
        ]
    }
