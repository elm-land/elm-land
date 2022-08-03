module Shared exposing
    ( Flags
    , Model, Msg(..)
    , init, update, subscriptions
    )

{-|

@docs Flags
@docs Model, Msg
@docs init, update, subscriptions

-}

import Http
import Json.Decode
import Route exposing (Route)



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


type alias User =
    { id : Int
    , name : String
    , profileImageUrl : String
    , email : String
    }


userDecoder : Json.Decode.Decoder User
userDecoder =
    Json.Decode.map4 User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "profileImageUrl" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


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
            Http.get
                { url = "http://localhost:5000/api/me?token=" ++ token
                , expect = Http.expectJson UserApiResponded userDecoder
                }

        Nothing ->
            Cmd.none
    )



-- UPDATE


type Msg
    = UserApiResponded (Result Http.Error User)


update : Route () -> Msg -> Model -> ( Model, Cmd Msg )
update req msg model =
    case msg of
        UserApiResponded (Ok user) ->
            ( { model | signInStatus = SignedInWithUser user }
            , Cmd.none
            )

        UserApiResponded (Err httpError) ->
            ( { model | signInStatus = FailedToSignIn httpError }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions req model =
    Sub.none
