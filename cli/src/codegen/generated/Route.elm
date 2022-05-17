module Route exposing (Route(..), fromUrl)

{-| 
@docs Route, fromUrl
-}


import Url
import Url.Parser


type Route
    = Home_
    | SignIn
    | Settings
    | People__Username_ { username : String }
    | NotFound_


fromUrl : Url.Url -> Route
fromUrl url =
    Maybe.withDefault NotFound_ (Url.Parser.parse routeParser url)


{-| -- ELM-CODEGEN ERROR --

I found

    Url.Parser.Parser a_2_2 b_2_2

But I was expecting:

    ()


-}
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map Home_ Url.Parser.top
        , Url.Parser.map SignIn ()
        , Url.Parser.map Settings ()
        , Url.Parser.map People__Username_ ()
        ]


