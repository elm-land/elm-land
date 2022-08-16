module Effect exposing
    ( Effect, none, batch, map
    , fromCmd
    , SharedMsg(..), fromSharedMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , toCmd
    )

{-|

@docs Effect, none, batch, map
@docs fromCmd
@docs SharedMsg, fromSharedMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Route exposing (Route)
import Route.Path
import Route.Query
import Task
import Url exposing (Url)


type Effect msg
    = None
    | Batch (List (Effect msg))
    | Cmd (Cmd msg)
    | Effect SharedMsg
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String


type SharedMsg
    = ExampleMsgReplaceMe


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        Effect msg ->
            Effect msg

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromSharedMsg : SharedMsg -> Effect msg
fromSharedMsg =
    Effect



-- ROUTING


pushRoute :
    { path : Route.Path.Path
    , query : List ( String, Maybe String )
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (toStringFromRouteFragment route)


replaceRoute :
    { path : Route.Path.Path
    , query : List ( String, Maybe String )
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (toStringFromRouteFragment route)


loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl



-- Used by Main.elm


toCmd :
    { key : Browser.Navigation.Key
    , fromSharedMsg : SharedMsg -> mainMsg
    , fromPageMsg : msg -> mainMsg
    }
    -> Effect msg
    -> Cmd mainMsg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map options.fromPageMsg cmd

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        Effect msg ->
            Task.succeed msg
                |> Task.perform options.fromSharedMsg

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url



-- INTERNALS


toStringFromRouteFragment :
    { path : Route.Path.Path
    , query : List ( String, Maybe String )
    , hash : Maybe String
    }
    -> String
toStringFromRouteFragment route =
    String.join ""
        [ Route.Path.toString route.path
        , Route.Query.toStringFromList route.query |> Maybe.withDefault ""
        , route.hash |> Maybe.map (String.append "#") |> Maybe.withDefault ""
        ]
