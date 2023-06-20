module Pages.Blog.ALL_ exposing (page)

import Html exposing (Html)
import View exposing (View)


page : { all_ : List String } -> View msg
page params =
    { title = "Pages.Blog.ALL_"
    , body =
        [ Html.text
            ("Catch-all route parameters: " ++ String.join ", " params.all_)
        ]
    }
