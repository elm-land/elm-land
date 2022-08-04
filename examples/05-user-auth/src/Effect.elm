port module Effect exposing
    ( Effect, none, map, batch
    , fromCmd, fromSharedMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , save
    , toCmd
    )

{-|

@docs Effect, none, map, batch
@docs fromCmd, fromSharedMsg
@docs pushRoute, replaceRoute, loadExternalUrl
@docs save
@docs toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Json.Encode
import Route exposing (Route)
import Route.Path
import Route.Query
import Shared
import Task
import Url exposing (Url)


type Effect msg
    = None
    | Cmd (Cmd msg)
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
    | Shared Shared.Msg
    | SaveToLocalStorage { key : String, value : Json.Encode.Value }
    | Batch (List (Effect msg))


none : Effect msg
none =
    None


map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        Shared msg ->
            Shared msg

        Batch list ->
            Batch (List.map (map fn) list)

        SaveToLocalStorage options ->
            SaveToLocalStorage options


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromSharedMsg : Shared.Msg -> Effect msg
fromSharedMsg =
    Shared



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



-- LOCAL STORAGE


save : { key : String, value : Json.Encode.Value } -> Effect msg
save keyValueRecord =
    SaveToLocalStorage keyValueRecord


batch : List (Effect msg) -> Effect msg
batch =
    Batch



-- Used by Main.elm


toCmd :
    { key : Browser.Navigation.Key
    , fromSharedMsg : Shared.Msg -> mainMsg
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

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        Shared msg ->
            Task.succeed msg
                |> Task.perform options.fromSharedMsg

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SaveToLocalStorage keyValueRecord ->
            saveToLocalStorage keyValueRecord



-- PORTS


port saveToLocalStorage : { key : String, value : Json.Encode.Value } -> Cmd msg



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