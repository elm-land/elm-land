port module Effect exposing
    ( Effect, none, map, batch
    , fromCmd, fromSharedMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , pushUrlPath
    , save
    , toCmd
    )

{-|

@docs Effect, none, map, batch
@docs fromCmd, fromSharedMsg
@docs Msg, fromAction
@docs pushRoute, replaceRoute, loadExternalUrl
@docs pushUrlPath
@docs save
@docs toCmd

-}

import Api.User
import Browser.Navigation
import Dict exposing (Dict)
import Http
import Json.Encode
import Route exposing (Route)
import Route.Path
import Route.Query
import Shared.Msg
import Task
import Url exposing (Url)


type Effect msg
    = None
    | Batch (List (Effect msg))
    | Cmd (Cmd msg)
    | Shared Shared.Msg.Msg
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
    | SaveToLocalStorage { key : String, value : Json.Encode.Value }


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromSharedMsg : Shared.Msg.Msg -> Effect msg
fromSharedMsg =
    Shared



-- ROUTING


pushUrlPath : String -> Effect msg
pushUrlPath str =
    PushUrl str


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



-- LOCAL STORAGE


port saveToLocalStorage : { key : String, value : Json.Encode.Value } -> Cmd msg


save : { key : String, value : Json.Encode.Value } -> Effect msg
save keyValueRecord =
    SaveToLocalStorage keyValueRecord



-- MAP


map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        Shared msg ->
            Shared msg

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SaveToLocalStorage options ->
            SaveToLocalStorage options



-- Used by Main.elm


toCmd :
    { key : Browser.Navigation.Key
    , fromSharedMsg : Shared.Msg.Msg -> mainMsg
    , toMainMsg : msg -> mainMsg
    , shared : sharedModel
    , url : Url
    }
    -> Effect msg
    -> Cmd mainMsg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        Cmd cmd ->
            Cmd.map options.toMainMsg cmd

        Shared msg ->
            Task.succeed msg
                |> Task.perform options.fromSharedMsg

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SaveToLocalStorage keyValueRecord ->
            saveToLocalStorage keyValueRecord
