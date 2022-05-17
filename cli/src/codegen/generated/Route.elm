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


routeParser : Url.Parser.Parser (Route -> x) x
routeParser =
    Url.Parser.oneOf
        [ Url.Parser.map Home_ Url.Parser.top
        , Url.Parser.map SignIn (Url.Parser.s "sign-in")
        , Url.Parser.map Settings (Url.Parser.s "settings")
        , Url.Parser.map
            People__Username_
            (Url.Parser.s "people" </> Url.Parser.string)
        ]


