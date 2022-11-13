port module Effect exposing
    ( Effect, none, batch
    , fromCmd
    , pushRoute, replaceRoute, loadExternalUrl
    , sendHttpGet
    , map, toCmd
    )

{-|

@docs Effect, none, batch
@docs fromCmd
@docs pushRoute, replaceRoute, loadExternalUrl

@docs sendHttpGet

@docs map, toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Http
import Json.Decode
import Json.Encode
import Route exposing (Route)
import Route.Path
import Route.Query
import Task
import Url exposing (Url)



-- PORTS


port sendHttpErrorToSentry :
    { url : String
    , response : Maybe String
    , error : String
    }
    -> Cmd msg


port sendJsonDecodeErrorToSentry :
    { url : String
    , response : String
    , error : String
    }
    -> Cmd msg



-- EFFECTS


type Effect msg
    = None
    | Batch (List (Effect msg))
    | Cmd (Cmd msg)
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
    | HttpGet
        { url : String
        , decoder : Json.Decode.Decoder msg
        , onHttpError : Http.Error -> msg
        }


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl


{-| Send an HTTP get request, with error reporting built-in!
-}
sendHttpGet :
    { url : String
    , decoder : Json.Decode.Decoder value
    , onResult : Result Http.Error value -> msg
    }
    -> Effect msg
sendHttpGet options =
    let
        onSuccess : value -> msg
        onSuccess value =
            options.onResult (Ok value)

        onHttpError : Http.Error -> msg
        onHttpError httpError =
            options.onResult (Err httpError)
    in
    HttpGet
        { url = options.url
        , decoder = Json.Decode.map onSuccess options.decoder
        , onHttpError = onHttpError
        }



-- TRANSFORMING EFFECTS


{-| Elm Land needs this function to connect your pages and layouts together into one app
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        HttpGet data ->
            HttpGet
                { url = data.url
                , onHttpError = \httpError -> fn (data.onHttpError httpError)
                , decoder = Json.Decode.map fn data.decoder
                }


{-| Elm Land needs this function to actually perform your Effects
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : sharedModel
    , fromSharedMsg : sharedMsg -> mainMsg
    , fromCmd : Cmd mainMsg -> mainMsg
    , toCmd : mainMsg -> Cmd mainMsg
    , toMainMsg : msg -> mainMsg
    }
    -> Effect msg
    -> Cmd mainMsg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map options.toMainMsg cmd

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        HttpGet request ->
            sendHttpGetRequestWithErrorReporting options request



-- AUTOMATIC ERROR REPORTING


sendHttpGetRequestWithErrorReporting :
    { options
        | toCmd : mainMsg -> Cmd mainMsg
        , fromCmd : Cmd mainMsg -> mainMsg
        , toMainMsg : msg -> mainMsg
    }
    ->
        { url : String
        , onHttpError : Http.Error -> msg
        , decoder : Json.Decode.Decoder msg
        }
    -> Cmd mainMsg
sendHttpGetRequestWithErrorReporting options request =
    let
        onHttpError : Http.Error -> mainMsg
        onHttpError error =
            options.toMainMsg (request.onHttpError error)

        toMsg : Result CustomError mainMsg -> mainMsg
        toMsg =
            fromCustomResultToMsg
                { url = request.url
                , toCmd = options.toCmd
                , fromCmd = options.fromCmd
                , onHttpError = onHttpError
                }

        fromHttpResponse : Http.Response String -> Result CustomError mainMsg
        fromHttpResponse =
            fromHttpResponseToCustomResult
                { decoder = Json.Decode.map options.toMainMsg request.decoder
                }
    in
    Http.get
        { url = request.url
        , expect =
            Http.expectStringResponse toMsg fromHttpResponse
        }


{-| Because we want to send Sentry the actual JSON response,
`Http.Error` won't be enough.

For that reason, we make our own `CustomError` type that can store
more data about the HTTP request.

-}
type CustomError
    = JsonDecodeError { response : String, reason : String }
    | OtherHttpError { response : Maybe String, reason : Http.Error }


toHttpError : CustomError -> Http.Error
toHttpError customError =
    case customError of
        JsonDecodeError { response, reason } ->
            Http.BadBody reason

        OtherHttpError { reason } ->
            reason


httpErrorToJsonString : Http.Error -> String
httpErrorToJsonString httpError =
    let
        httpErrorAsJson : Json.Decode.Value
        httpErrorAsJson =
            case httpError of
                Http.BadBody _ ->
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "BadBody" )
                        ]

                Http.BadUrl url ->
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "BadUrl" )
                        ]

                Http.Timeout ->
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "Timeout" )
                        ]

                Http.NetworkError ->
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "NetworkError" )
                        ]

                Http.BadStatus code ->
                    Json.Encode.object
                        [ ( "tag", Json.Encode.string "BadStatus" )
                        , ( "code", Json.Encode.int code )
                        ]
    in
    Json.Encode.encode 2 httpErrorAsJson


fromCustomResultToMsg :
    { url : String
    , fromCmd : Cmd msg -> msg
    , toCmd : msg -> Cmd msg
    , onHttpError : Http.Error -> msg
    }
    -> Result CustomError msg
    -> msg
fromCustomResultToMsg options result =
    case result of
        Ok msg ->
            msg

        Err customError ->
            options.fromCmd
                (Cmd.batch
                    [ -- Let the original page handle the error
                      customError
                        |> toHttpError
                        |> options.onHttpError
                        |> options.toCmd
                    , -- Report the error to Sentry
                      case customError of
                        JsonDecodeError { response, reason } ->
                            sendJsonDecodeErrorToSentry
                                { url = options.url
                                , response = response
                                , error = reason
                                }

                        OtherHttpError { response, reason } ->
                            sendHttpErrorToSentry
                                { url = options.url
                                , response = response
                                , error = httpErrorToJsonString reason
                                }
                    ]
                )


fromHttpResponseToCustomResult : { decoder : Json.Decode.Decoder msg } -> Http.Response String -> Result CustomError msg
fromHttpResponseToCustomResult options httpResponse =
    case httpResponse of
        Http.BadUrl_ url_ ->
            -- means you did not provide a valid URL.
            Err (OtherHttpError { response = Nothing, reason = Http.BadUrl url_ })

        Http.Timeout_ ->
            -- means it took too long to get a response.
            Err (OtherHttpError { response = Nothing, reason = Http.Timeout })

        Http.NetworkError_ ->
            -- means the user turned off their wifi, went in a cave, etc.
            Err (OtherHttpError { response = Nothing, reason = Http.NetworkError })

        Http.BadStatus_ metadata response ->
            -- means you got a response back, but the status code indicates failure.
            Err
                (OtherHttpError
                    { response = Just response
                    , reason = Http.BadStatus metadata.statusCode
                    }
                )

        Http.GoodStatus_ metadata response ->
            -- means you got a response back with a nice status code!
            case Json.Decode.decodeString options.decoder response of
                Ok msg ->
                    Ok msg

                Err jsonDecodeError ->
                    Err
                        (JsonDecodeError
                            { response = response
                            , reason = Json.Decode.errorToString jsonDecodeError
                            }
                        )
