module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    , SignInStatus(..)
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions
@docs handleSharedMsg

@docs SignInStatus

-}

import Api.User exposing (User)
import Browser.Navigation
import Dict
import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode
import Route exposing (Route)
import Route.Path
import Shared.Msg exposing (Msg(..))



-- INIT


type alias Flags =
    { token : Maybe String
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.maybe (Json.Decode.field "token" Json.Decode.string))


type alias Model =
    { signInStatus : SignInStatus
    }


type SignInStatus
    = NotSignedIn
    | SignedInWithToken String
    | SignedInWithUser User
    | FailedToSignIn Http.Error


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags : Flags
        flags =
            flagsResult
                |> Result.withDefault { token = Nothing }

        signInStatus : SignInStatus
        signInStatus =
            case flags.token of
                Nothing ->
                    NotSignedIn

                Just token ->
                    SignedInWithToken token
    in
    ( { signInStatus = signInStatus
      }
    , case flags.token of
        Just token ->
            Effect.fromCmd
                (Api.User.getCurrentUser
                    { token = token
                    , onResponse = UserApiResponded
                    }
                )

        Nothing ->
            Effect.none
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        UserApiResponded (Ok user) ->
            ( { model | signInStatus = SignedInWithUser user }
            , Effect.none
            )

        UserApiResponded (Err httpError) ->
            ( { model | signInStatus = FailedToSignIn httpError }
            , Effect.none
            )

        SignInPageSignedInUser (Ok user) ->
            ( { model | signInStatus = SignedInWithUser user }
            , case Dict.get "from" route.query of
                Just redirectUrlPath ->
                    Effect.pushUrlPath redirectUrlPath

                Nothing ->
                    Effect.pushRoute
                        { path = Route.Path.Home_
                        , query = Dict.empty
                        , hash = Nothing
                        }
            )

        SignInPageSignedInUser (Err httpError) ->
            ( { model | signInStatus = FailedToSignIn httpError }
            , Effect.none
            )

        PageSignedOutUser ->
            ( { model | signInStatus = NotSignedIn }
            , Effect.save { key = "token", value = Json.Encode.null }
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Sub.none
