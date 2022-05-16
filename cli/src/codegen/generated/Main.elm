module Main exposing (main)

{-| 
@docs main
-}


import Browser
import Browser.Navigation
import Html
import Json.Decode
import Url


type alias Flags =
    Json.Decode.Value


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }


{- INIT -}


type alias Model =
    { flags : Flags, key : Browser.Navigation.Key, url : Url.Url }


{-| -- ELM-CODEGEN ERROR --

I found

    Model

But I was expecting:

    {flags : flags, url : url, key : key}


-}
init flags url key =
    ( { flags = flags, url = url, key = key }, Cmd.none )


{- UPDATE -}


type Msg
    = UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequested (Browser.Internal url) ->
            ( model
            , Browser.Navigation.pushUrl model.key (Url.toString url)
            )

        UrlRequested (Browser.External url) ->
            ( model
            , Browser.Navigation.load url
            )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )


subscriptions : model -> Sub Msg
subscriptions model =
    Sub.none


{- VIEW -}


view : model -> { title : String, body : List (Html.Html Msg) }
view model =
    { title = "App", body = [ Html.text "Hey" ] }


