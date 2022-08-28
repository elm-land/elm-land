module Route exposing
    ( Route, fromUrl
    , href, toString
    )

{-|

@docs Route, fromUrl
@docs href, toString

-}

import Dict exposing (Dict)
import Html
import Html.Attributes
import Route.Path
import Route.Query
import Url exposing (Url)
import Url.Parser exposing ((</>), query)


type alias Route params =
    { path : Route.Path.Path
    , params : params
    , query : Dict String (Maybe String)
    , hash : Maybe String
    , url : Url
    }


fromUrl : params -> Url -> Route params
fromUrl params url =
    { path = Route.Path.fromUrl url
    , params = params
    , query = Route.Query.fromUrl url
    , hash = url.fragment
    , url = url
    }


href :
    { path : Route.Path.Path
    , query : List ( String, Maybe String )
    , hash : Maybe String
    }
    -> Html.Attribute msg
href route =
    Html.Attributes.href (toString route)


toString :
    { route
        | path : Route.Path.Path
        , query : List ( String, Maybe String )
        , hash : Maybe String
    }
    -> String
toString route =
    String.join ""
        [ Route.Path.toString route.path
        , Route.Query.toStringFromList route.query |> Maybe.withDefault ""
        , route.hash |> Maybe.map (String.append "#") |> Maybe.withDefault ""
        ]
