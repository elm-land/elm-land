module Pages.Home_ exposing (page)

import Css
import Html.Styled
import Html.Styled.Attributes
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body =
        [ Html.Styled.h1
            [ Html.Styled.Attributes.css
                [ Css.fontFamily Css.sansSerif
                , Css.displayFlex
                , Css.alignItems Css.center
                , Css.justifyContent Css.center
                , Css.height (Css.vh 95)
                ]
            ]
            [ Html.Styled.text "Hello, Elm CSS!" ]
        ]
    }
