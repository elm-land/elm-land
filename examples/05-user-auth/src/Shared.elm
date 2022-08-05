module Shared exposing
    ( Flags
    , Model, Msg
    , init, update, subscriptions
    , handleEffectMsg
    , SignInStatus(..)
    )

{-|

@docs Flags
@docs Model, Msg
@docs init, update, subscriptions
@docs handleEffectMsg

@docs SignInStatus

-}

import Api.User exposing (User)
import Browser.Navigation
import Effect exposing (Effect)
import Http
import Json.Decode
import Route exposing (Route)
import Route.Path



-- INIT


type alias Flags =
    Json.Decode.Value


type alias SafeFlags =
    { token : Maybe String
    }


flagsDecoder : Json.Decode.Decoder SafeFlags
flagsDecoder =
    Json.Decode.map SafeFlags
        (Json.Decode.maybe (Json.Decode.field "token" Json.Decode.string))


type alias Model =
    { signInStatus : SignInStatus
    }


type SignInStatus
    = NotSignedIn
    | SignedInWithToken String
    | SignedInWithUser User
    | FailedToSignIn Http.Error


init : Flags -> Route () -> ( Model, Effect Msg )
init json req =
    let
        flags : SafeFlags
        flags =
            json
                |> Json.Decode.decodeValue flagsDecoder
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


type Msg
    = UserApiResponded (Result Http.Error User)
    | FromEffect Effect.Msg


handleEffectMsg : Effect.Msg -> Msg
handleEffectMsg =
    FromEffect


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

        FromEffect (Effect.SignInPageSignedInUser (Ok user)) ->
            ( { model | signInStatus = SignedInWithUser user }
            , Effect.pushRoute
                { path = Route.Path.Home_
                , query = []
                , hash = Nothing
                }
            )

        FromEffect (Effect.SignInPageSignedInUser (Err httpError)) ->
            ( { model | signInStatus = FailedToSignIn httpError }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions req model =
    Sub.none
