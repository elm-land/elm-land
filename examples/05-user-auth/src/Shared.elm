module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Api.Me
import Browser.Navigation
import Dict
import Domain.SignInStatus
import Domain.User exposing (User)
import Effect exposing (Effect)
import Http
import Json.Decode
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg



-- INIT


type alias Flags =
    { token : Maybe String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.maybe (Json.Decode.field "token" Json.Decode.string))


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            flagsResult
                |> Result.withDefault { token = Nothing }

        signInStatus : Domain.SignInStatus.SignInStatus
        signInStatus =
            case flags.token of
                Nothing ->
                    Domain.SignInStatus.NotSignedIn

                Just token ->
                    Domain.SignInStatus.SignedInWithToken token
    in
    ( { signInStatus = signInStatus
      }
    , case flags.token of
        Just token ->
            Api.Me.get
                { token = token
                , onResponse = Shared.Msg.ApiMeResponded
                }

        Nothing ->
            Effect.none
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.ApiMeResponded (Ok user) ->
            ( { model | signInStatus = Domain.SignInStatus.SignedInWithUser user }
            , Effect.none
            )

        Shared.Msg.ApiMeResponded (Err httpError) ->
            ( { model | signInStatus = Domain.SignInStatus.FailedToSignIn httpError }
            , Effect.none
            )

        Shared.Msg.SignInPageSignedInUser (Ok user) ->
            let
                redirectRoute : Maybe Route.Path.Path
                redirectRoute =
                    Dict.get "from" route.query
                        |> Maybe.andThen Route.Path.fromString
            in
            ( { model | signInStatus = Domain.SignInStatus.SignedInWithUser user }
            , Effect.pushRoute
                { path =
                    redirectRoute
                        |> Maybe.withDefault Route.Path.Home_
                , query = Dict.empty
                , hash = Nothing
                }
            )

        Shared.Msg.SignInPageSignedInUser (Err httpError) ->
            ( { model | signInStatus = Domain.SignInStatus.FailedToSignIn httpError }
            , Effect.none
            )

        Shared.Msg.PageSignedOutUser ->
            ( { model | signInStatus = Domain.SignInStatus.NotSignedIn }
            , Effect.resetUserToken
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
