module Main exposing (main)

{-| 
@docs main
-}


import Browser
import Browser.Navigation
import Html
import Json.Decode
import Pages.Home_
import Pages.NotFound_
import Pages.People.Username_
import Pages.Settings
import Pages.SignIn
import Route
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


init : Flags -> Url.Url -> Browser.Navigation.Key -> (Model, Cmd Msg)
init flags url key =
    ( { flags = flags
      , url = url
      , key = key
      }
    , Cmd.none
    )


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


view : model -> { title : String, body : List viewPage_1_0_0_1_1_0_0_result }
view model =
    { title = "App", body = [ viewPage model ] }


viewPage : model -> Html.Html Msg
viewPage model =
    case Route.fromUrl model.url of
        Route.Home_ ->
            Pages.Home_.page

        Route.SignIn ->
            Pages.SignIn.page

        Route.Settings ->
            Pages.Settings.page

        Route.People__Username_ one_4_0_0 ->
            Pages.People.Username_.page one_4_0_0

        Route.NotFound_ ->
            Pages.NotFound_.page


