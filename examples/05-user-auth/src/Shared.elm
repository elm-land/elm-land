module Shared exposing
    ( Flags
    , Model, Msg(..)
    , init, update, subscriptions
    , SignInStatus(..)
    )

{-|

@docs Flags
@docs Model, Msg
@docs init, update, subscriptions

@docs SignInStatus

-}

import Api.User exposing (User)
import Browser.Navigation
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


init : Flags -> Route () -> ( Model, Cmd Msg )
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
            Api.User.getCurrentUser
                { token = token
                , onResponse = UserApiResponded
                }

        Nothing ->
            Cmd.none
    )



-- UPDATE


type Msg
    = UserApiResponded (Result Http.Error User)
    | SignInPageSignedInUser (Result Http.Error User)


update : Browser.Navigation.Key -> Route () -> Msg -> Model -> ( Model, Cmd Msg )
update key route msg model =
    case msg of
        UserApiResponded (Ok user) ->
            ( { model | signInStatus = SignedInWithUser user }
            , Cmd.none
            )

        UserApiResponded (Err httpError) ->
            ( { model | signInStatus = FailedToSignIn httpError }
            , Cmd.none
            )

        SignInPageSignedInUser (Ok user) ->
            ( { model | signInStatus = SignedInWithUser user }
            , Browser.Navigation.pushUrl key
                (Route.Path.toString Route.Path.Home_)
            )

        SignInPageSignedInUser (Err httpError) ->
            ( { model | signInStatus = FailedToSignIn httpError }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions req model =
    Sub.none
