module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    , onUrlRequest
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions
@docs onUrlRequest

-}

import Browser
import Browser.Events
import Effect exposing (Effect)
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg exposing (Msg(..))



-- FLAGS


type alias Flags =
    Model


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map2 Shared.Model.Model
        (Json.Decode.field "width" Json.Decode.int)
        (Json.Decode.field "height" Json.Decode.int)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            case flagsResult of
                Ok size ->
                    size

                Err _ ->
                    { windowWidth = 0, windowHeight = 0 }
    in
    ( flags, Effect.none )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        WindowResized w h ->
            ( Shared.Model.Model w h
            , Effect.none
            )

        Shared.Msg.UrlRequested (Browser.Internal url) ->
            ( model
            , let
                { path, query, hash } =
                    Route.fromUrl () url
              in
              Effect.pushRoute
                { path = path
                , query = query
                , hash = hash
                }
            )

        Shared.Msg.UrlRequested (Browser.External url) ->
            if String.isEmpty (String.trim url) then
                ( model, Effect.none )

            else
                ( model
                , Effect.loadExternalUrl url
                )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onResize WindowResized



-- APPLICATION CONFIGURATION


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest =
    Shared.Msg.UrlRequested
