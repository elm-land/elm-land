module Pages.Blog.ALL_ exposing (page)

import Html exposing (Html)
import View exposing (View)


page : { all_ : ( String, List String ) } -> View msg
page params =
    let
        nestedParameters : List String
        nestedParameters =
            case params.all_ of
                ( first, rest ) ->
                    first :: rest
    in
    { title = "Pages.Blog.ALL_"
    , body =
        [ Html.text
            ("Catch-all route parameters: "
                ++ String.join ", " nestedParameters
            )
        ]
    }
