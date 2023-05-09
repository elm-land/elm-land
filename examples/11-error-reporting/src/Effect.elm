port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , sendHttpGet
    , map, toCmd
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
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
import Shared.Model
import Shared.Msg
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
    = -- BASICS
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- ROUTING
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- SHARED
    | SendSharedMsg Shared.Msg.Msg
      -- HTTP
    | HttpRequest (HttpRequestDetails msg)


type alias HttpRequestDetails msg =
    { method : String
    , url : String
    , headers : List Http.Header
    , body : Http.Body
    , timeout : Maybe Float
    , tracker : Maybe String
    , decoder : Json.Decode.Decoder msg
    , onHttpError : Http.Error -> msg
    }



-- BASICS


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


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



-- HTTP


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
    HttpRequest
        { method = "GET"
        , url = options.url
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        , decoder = Json.Decode.map onSuccess options.decoder
        , onHttpError = onHttpError
        }



-- INTERALS


{-| Elm Land needs this function to connect your pages and layouts together into one app
-}
map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SendSharedMsg msg ->
            SendSharedMsg msg

        HttpRequest data ->
            HttpRequest
                { method = data.method
                , url = data.url
                , headers = data.headers
                , body = data.body
                , timeout = data.timeout
                , tracker = data.tracker
                , onHttpError = \httpError -> fn (data.onHttpError httpError)
                , decoder = Json.Decode.map fn data.decoder
                }


{-| Elm Land needs this function to actually perform your Effects
-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> msg
    , fromCmd : Cmd msg -> msg
    , toCmd : msg -> Cmd msg
    }
    -> Effect msg
    -> Cmd msg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg msg ->
            Task.succeed msg
                |> Task.perform options.fromSharedMsg

        HttpRequest request ->
            sendGetRequestWithErrorReporting options request



-- AUTOMATIC ERROR REPORTING


sendGetRequestWithErrorReporting :
    { options
        | toCmd : msg -> Cmd msg
        , fromCmd : Cmd msg -> msg
    }
    -> HttpRequestDetails msg
    -> Cmd msg
sendGetRequestWithErrorReporting options request =
    let
        toMsg : Result CustomError msg -> msg
        toMsg =
            fromCustomResultToMsg
                { url = request.url
                , toCmd = options.toCmd
                , fromCmd = options.fromCmd
                , onHttpError = request.onHttpError
                }

        fromHttpResponse : Http.Response String -> Result CustomError msg
        fromHttpResponse =
            fromHttpResponseToCustomResult
                { decoder = request.decoder
                }
    in
    Http.request
        { method = request.method
        , url = request.url
        , headers = request.headers
        , body = request.body
        , timeout = request.timeout
        , tracker = request.tracker
        , expect = Http.expectStringResponse toMsg fromHttpResponse
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
