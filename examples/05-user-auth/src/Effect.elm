port module Effect exposing
    ( Effect, none, map, batch
    , fromCmd
    , SharedMsg(..), fromSharedMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , save
    , toCmd
    )

{-|

@docs Effect, none, map, batch
@docs fromCmd
@docs SharedMsg, fromSharedMsg
@docs Msg, fromAction
@docs pushRoute, replaceRoute, loadExternalUrl
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
import Task
import Url exposing (Url)


type Effect msg
    = None
    | Batch (List (Effect msg))
    | Cmd (Cmd msg)
    | Shared SharedMsg
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
    | SaveToLocalStorage { key : String, value : Json.Encode.Value }


type SharedMsg
    = SignInPageSignedInUser (Result Http.Error Api.User.User)
    | PageSignedOutUser


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromSharedMsg : SharedMsg -> Effect msg
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
    , fromSharedMsg : SharedMsg -> mainMsg
    , fromPageMsg : msg -> mainMsg
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
            Cmd.map options.fromPageMsg cmd

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
