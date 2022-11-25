port module Effect exposing
    ( Effect
    , none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , signIn, signOut
    , saveUserToken, clearUserToken
    , map, toCmd
    )

{-|

@docs Effect
@docs none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs signIn, signOut
@docs saveUserToken, clearUserToken

@docs map, toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Domain.User
import Http
import Json.Encode
import Route exposing (Route)
import Route.Path
import Route.Query
import Shared.Model
import Shared.Msg
import Task
import Url exposing (Url)


type Effect msg
    = -- Basics
      None
    | Batch (List (Effect msg))
    | SendCmd (Cmd msg)
      -- Routing
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- Shared
    | SendSharedMsg Shared.Msg.Msg
      -- Custom
    | SaveToLocalStorage { key : String, value : Json.Encode.Value }



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



-- SHARED


signIn : Result Http.Error Domain.User.User -> Effect msg
signIn result =
    SendSharedMsg (Shared.Msg.SignInPageSignedInUser result)


signOut : Effect msg
signOut =
    SendSharedMsg Shared.Msg.PageSignedOutUser



-- LOCAL STORAGE


port saveToLocalStorage : { key : String, value : Json.Encode.Value } -> Cmd msg


saveUserToken : String -> Effect msg
saveUserToken token =
    SaveToLocalStorage
        { key = "token"
        , value = Json.Encode.string token
        }


clearUserToken : Effect msg
clearUserToken =
    SaveToLocalStorage
        { key = "token"
        , value = Json.Encode.null
        }



-- INTERNALS


map : (msg1 -> msg2) -> Effect msg1 -> Effect msg2
map fn effect =
    case effect of
        None ->
            None

        Batch list ->
            Batch (List.map (map fn) list)

        SendCmd cmd ->
            SendCmd (Cmd.map fn cmd)

        SendSharedMsg msg ->
            SendSharedMsg msg

        PushUrl url ->
            PushUrl url

        ReplaceUrl url ->
            ReplaceUrl url

        LoadExternalUrl url ->
            LoadExternalUrl url

        SaveToLocalStorage options ->
            SaveToLocalStorage options


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

        SendSharedMsg msg ->
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
