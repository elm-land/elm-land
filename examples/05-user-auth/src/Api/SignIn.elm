module Api.SignIn exposing (Field(..), FormError, post)

import Effect exposing (Effect)
import Http
import Json.Decode
import Json.Encode


type Field
    = Email
    | Password


type alias FormError =
    { field : Maybe Field
    , message : String
    }


post :
    { email : String
    , password : String
    , onResponse : Result (List FormError) String -> msg
    }
    -> Effect msg
post options =
    let
        json : Json.Encode.Value
        json =
            Json.Encode.object
                [ ( "email", Json.Encode.string options.email )
                , ( "password", Json.Encode.string options.password )
                ]

        tokenDecoder : Json.Decode.Decoder String
        tokenDecoder =
            Json.Decode.field "token" Json.Decode.string

        httpCmd : Cmd msg
        httpCmd =
            Http.post
                { url = "http://localhost:5000/api/sign-in"
                , body = Http.jsonBody json
                , expect =
                    expectHttpResponse
                        { onResponse = options.onResponse
                        , decoderForGoodStatusCode = tokenDecoder
                        , decoderForBadStatusCode = formErrorsDecoder
                        }
                }
    in
    Effect.fromCmd httpCmd


formErrorsDecoder : Json.Decode.Decoder (List FormError)
formErrorsDecoder =
    let
        formErrorDecoder : Json.Decode.Decoder FormError
        formErrorDecoder =
            Json.Decode.map2 FormError
                (Json.Decode.field "field" maybeFieldDecoder)
                (Json.Decode.field "message" Json.Decode.string)

        maybeFieldDecoder : Json.Decode.Decoder (Maybe Field)
        maybeFieldDecoder =
            Json.Decode.string
                |> Json.Decode.map fromStringToMaybeField

        fromStringToMaybeField : String -> Maybe Field
        fromStringToMaybeField field =
            case field of
                "email" ->
                    Just Email

                "password" ->
                    Just Password

                _ ->
                    Nothing
    in
    Json.Decode.field "errors" (Json.Decode.list formErrorDecoder)


expectHttpResponse :
    { onResponse : Result (List FormError) value -> msg
    , decoderForGoodStatusCode : Json.Decode.Decoder value
    , decoderForBadStatusCode : Json.Decode.Decoder (List FormError)
    }
    -> Http.Expect msg
expectHttpResponse options =
    let
        fromHttpStringResponse :
            Http.Response String
            -> Result (List FormError) value
        fromHttpStringResponse response =
            case response of
                Http.BadUrl_ _ ->
                    Err
                        [ { field = Nothing
                          , message = "Unexpected URL format"
                          }
                        ]

                Http.Timeout_ ->
                    Err
                        [ { field = Nothing
                          , message = "Server did not respond"
                          }
                        ]

                Http.NetworkError_ ->
                    Err
                        [ { field = Nothing
                          , message = "Could not connect to server"
                          }
                        ]

                Http.BadStatus_ { statusCode } rawJson ->
                    case Json.Decode.decodeString options.decoderForBadStatusCode rawJson of
                        Ok errors ->
                            Err errors

                        Err _ ->
                            Err
                                [ { field = Nothing
                                  , message = "Received status code " ++ String.fromInt statusCode
                                  }
                                ]

                Http.GoodStatus_ _ rawJson ->
                    case Json.Decode.decodeString options.decoderForGoodStatusCode rawJson of
                        Ok value ->
                            Ok value

                        Err _ ->
                            Err
                                [ { field = Nothing
                                  , message = "Received unexpected API response"
                                  }
                                ]
    in
    Http.expectStringResponse
        options.onResponse
        fromHttpStringResponse
