module Api.SignIn exposing (Data, Error, post)

import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode


{-| The data we expect if the sign in attempt was successful.
-}
type alias Data =
    { token : String
    }


{-| How to create a `Data` value from JSON
-}
decoder : Json.Decode.Decoder Data
decoder =
    Json.Decode.map Data
        (Json.Decode.field "token" Json.Decode.string)


type alias Error =
    { message : String
    , field : Maybe String
    }


{-| Sends a POST request to our `/api/sign-in` endpoint, which
returns our JWT token if a user was found with that email
and password.
-}
post :
    { onResponse : Result (List Error) Data -> msg
    , email : String
    , password : String
    }
    -> Effect msg
post options =
    let
        body : Json.Encode.Value
        body =
            Json.Encode.object
                [ ( "email", Json.Encode.string options.email )
                , ( "password", Json.Encode.string options.password )
                ]

        cmd : Cmd msg
        cmd =
            Http.post
                { url = "http://localhost:5000/api/sign-in"
                , body = Http.jsonBody body
                , expect =
                    Http.expectStringResponse
                        options.onResponse
                        handleHttpResponse
                }
    in
    Effect.sendCmd cmd


handleHttpResponse : Http.Response String -> Result (List Error) Data
handleHttpResponse response =
    case response of
        Http.BadUrl_ _ ->
            Err
                [ { message = "Unexpected URL format"
                  , field = Nothing
                  }
                ]

        Http.Timeout_ ->
            Err
                [ { message = "Request timed out, please try again"
                  , field = Nothing
                  }
                ]

        Http.NetworkError_ ->
            Err
                [ { message = "Could not connect, please try again"
                  , field = Nothing
                  }
                ]

        Http.BadStatus_ { statusCode } body ->
            case Json.Decode.decodeString errorsDecoder body of
                Ok errors ->
                    Err errors

                Err _ ->
                    Err
                        [ { message = "Something unexpected happened"
                          , field = Nothing
                          }
                        ]

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString decoder body of
                Ok data ->
                    Ok data

                Err _ ->
                    Err
                        [ { message = "Something unexpected happened"
                          , field = Nothing
                          }
                        ]


errorsDecoder : Json.Decode.Decoder (List Error)
errorsDecoder =
    Json.Decode.field "errors" (Json.Decode.list errorDecoder)


errorDecoder : Json.Decode.Decoder Error
errorDecoder =
    Json.Decode.map2 Error
        (Json.Decode.field "message" Json.Decode.string)
        (Json.Decode.field "field" (Json.Decode.maybe Json.Decode.string))
