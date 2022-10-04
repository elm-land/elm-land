module Effect exposing
    ( Effect, none, batch
    , fromCmd
    , pushRoute, replaceRoute, loadExternalUrl
    , sendQuery, sendMutation
    , map, toCmd
    )

{-|

@docs Effect, none, batch
@docs fromCmd
@docs pushRoute, replaceRoute, loadExternalUrl

@docs sendQuery, sendMutation

@docs map, toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import GraphQL
import GraphQL.Http
import Route exposing (Route)
import Route.Path
import Route.Query
import Shared.Model
import Task
import Url exposing (Url)


type Effect msg
    = None
    | Batch (List (Effect msg))
    | Cmd (Cmd msg)
    | PushUrl String
    | ReplaceUrl String
    | LoadExternalUrl String
    | SendQuery (GraphQLRequest msg)
    | SendMutation (GraphQLRequest msg)


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



-- GRAPHQL STUFF


sendQuery :
    { query : GraphQL.Query data
    , onResponse : Result GraphQL.Http.Error data -> msg
    }
    -> Effect msg
sendQuery options =
    SendQuery
        { operation = options.query |> GraphQL.map (\data -> options.onResponse (Ok data))
        , onError = \error -> options.onResponse (Err error)
        }


sendMutation :
    { mutation : GraphQL.Mutation data
    , onResponse : Result GraphQL.Http.Error data -> msg
    }
    -> Effect msg
sendMutation options =
    SendMutation
        { operation = options.mutation |> GraphQL.map (\data -> options.onResponse (Ok data))
        , onError = \error -> options.onResponse (Err error)
        }



-- TRANSFORMING EFFECTS


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

        SendQuery options ->
            SendQuery
                { operation = GraphQL.map fn options.operation
                , onError = \error -> options.onError error |> fn
                }

        SendMutation options ->
            SendMutation
                { operation = GraphQL.map fn options.operation
                , onError = \error -> options.onError error |> fn
                }


{-| ( Used by Elm Land to send real side-effects )
-}
toCmd :
    { key : Browser.Navigation.Key
    , shared : Shared.Model.Model
    , fromSharedMsg : sharedMsg -> mainMsg
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

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendQuery options_ ->
            sendGraphQLRequest options.shared options_
                |> Cmd.map options.fromPageMsg

        SendMutation options_ ->
            sendGraphQLRequest options.shared options_
                |> Cmd.map options.fromPageMsg



-- GRAPHQL REQUESTS


type alias GraphQLRequest msg =
    { operation : GraphQL.Query msg
    , onError : GraphQL.Http.Error -> msg
    }


sendGraphQLRequest : Shared.Model.Model -> GraphQLRequest msg -> Cmd msg
sendGraphQLRequest shared options =
    GraphQL.Http.run
        (GraphQL.Http.post { url = "https://api.github.com/graphql" }
            |> GraphQL.Http.withHeader "Authorization" ("Bearer " ++ shared.token)
            |> GraphQL.Http.withHeader "User-Agent" "@elm-land/graphql"
        )
        { operation = options.operation
        , onResponse =
            \result ->
                case result of
                    Ok msg ->
                        msg

                    Err httpError ->
                        options.onError httpError
        }
