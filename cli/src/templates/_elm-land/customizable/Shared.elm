module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    , handleEffectMsg
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions
@docs handleEffectMsg

-}

import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Route.Path



-- INIT


type alias Flags =
    {}


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.succeed {}


type alias Model =
    {}


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    ( {}
    , Effect.none
    )



-- UPDATE


type Msg
    = FromEffect Effect.Msg


handleEffectMsg : Effect.Msg -> Msg
handleEffectMsg =
    FromEffect


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        FromEffect Effect.ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
