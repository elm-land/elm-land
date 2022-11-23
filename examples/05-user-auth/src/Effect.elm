port module Effect exposing
    ( Effect, none, map, batch
    , fromCmd, fromMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , toCmd
    , signInPageSignedInUser, pageSignedOutUser
    , setUserToken, resetUserToken
    )

{-|

@docs Effect, none, map, batch
@docs fromCmd, fromMsg
@docs Msg, fromAction
@docs pushRoute, replaceRoute, loadExternalUrl
@docs toCmd

@docs signInPageSignedInUser, pageSignedOutUser

@docs setUserToken, resetUserToken

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
    | Cmd (Cmd msg)
      -- Routing
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
      -- Shared
    | Shared Shared.Msg.Msg
      -- Custom
    | SaveToLocalStorage { key : String, value : Json.Encode.Value }



-- BASICS


none : Effect msg
none =
    None


batch : List (Effect msg) -> Effect msg
batch =
    Batch


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromMsg : msg -> Effect msg
fromMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> Cmd



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


signInPageSignedInUser : Result Http.Error Domain.User.User -> Effect msg
signInPageSignedInUser result =
    Shared (Shared.Msg.SignInPageSignedInUser result)


pageSignedOutUser : Effect msg
pageSignedOutUser =
    Shared Shared.Msg.PageSignedOutUser



-- CUSTOM


port saveToLocalStorage : { key : String, value : Json.Encode.Value } -> Cmd msg


setUserToken : String -> Effect msg
setUserToken token =
    SaveToLocalStorage
        { key = "token"
        , value = Json.Encode.string token
        }


resetUserToken : Effect msg
resetUserToken =
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


toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> mainMsg
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
