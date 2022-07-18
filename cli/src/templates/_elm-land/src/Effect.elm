module Effect exposing
    ( Effect, none, map, batch
    , fromCmd, fromShared
    , toCmd
    )

{-|
@docs Effect, none, map, batch
@docs fromCmd, fromShared
@docs toCmd
-}

import Shared
import Task


type Effect msg
    = None
    | Cmd (Cmd msg)
    | Shared Shared.Msg
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

        Shared msg ->
            Shared msg

        Batch list ->
            Batch (List.map (map fn) list)


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromShared : Shared.Msg -> Effect msg
fromShared =
    Shared


batch : List (Effect msg) -> Effect msg
batch =
    Batch



-- Used by Main.elm


toCmd : { fromSharedMsg : Shared.Msg -> mainMsg, fromPageMsg : msg -> mainMsg } -> Effect msg -> Cmd mainMsg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map options.fromPageMsg cmd

        Shared msg ->
            Task.succeed msg
                |> Task.perform options.fromSharedMsg

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)