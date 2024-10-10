module Shared.Msg exposing (Msg(..))

{-| -}

import Browser
import Http
import Json.Decode


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type Msg
    = SendJsonDecodeErrorToSentry
        { method : String
        , url : String
        , response : String
        , error : Json.Decode.Error
        }
    | SendHttpErrorToSentry
        { method : String
        , url : String
        , response : Maybe String
        , error : Http.Error
        }
    | UrlRequested Browser.UrlRequest
