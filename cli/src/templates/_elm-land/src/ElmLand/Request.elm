module ElmLand.Request exposing
    ( Request, new
    )

{-|
@docs Request, new
-}
import Url exposing (Url)


type alias Request params =
    { url : Url
    , params : params
    }


new : params -> Url -> Request params
new params url =
    { url = url
    , params = params
    }