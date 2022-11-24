module Effect exposing
    ( Effect, none, batch
    , sendCmd, sendMsg
    , pushRoute, replaceRoute, loadExternalUrl
    , map, toCmd
    )

{-|

@docs Effect, none, batch
@docs sendCmd, sendMsg
@docs pushRoute, replaceRoute, loadExternalUrl

@docs map, toCmd

-}

import Browser.Navigation
import Dict exposing (Dict)
import Route exposing (Route)
import Route.Path
import Route.Query
import Shared.Model
import Shared.Msg
import Task
import Url exposing (Url)


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



-- BASICS


{-| Don't send any effect.
-}
none : Effect msg
none =
    None


{-| Send multiple effects at once.
-}
batch : List (Effect msg) -> Effect msg
batch =
    Batch


{-| Send a normal `Cmd msg` as an effect, something like `Http.get` or \`Random.generate.
-}
sendCmd : Cmd msg -> Effect msg
sendCmd =
    SendCmd


{-| Send a message as an effect. Useful when emitting events from UI components.
-}
sendMsg : msg -> Effect msg
sendMsg msg =
    Task.succeed msg
        |> Task.perform identity
        |> SendCmd



-- ROUTING


{-| Set the new route, and make the back button go back to the current route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
pushRoute route =
    PushUrl (Route.toString route)


{-| Set the new route, but replace the current one, so clicking the back
button **won't** go back to the previous route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Effect msg
replaceRoute route =
    ReplaceUrl (Route.toString route)


{-| Redirect users to a new URL, somewhere not in your web application.
-}
loadExternalUrl : String -> Effect msg
loadExternalUrl =
    LoadExternalUrl



-- SHARED MESSAGES


{-| This is intended to be a helper function for sending `Shared.Msg` values as
an `Effect msg`, but it's NOT recommended to expose this function to the rest of
your application.

Instead, we suggest exposing **specific** functions that use this one under-the-hood.
This design choice will make it easier to send effects from all your pages, layouts
and components.

Here's an example of the method described above:

    module Effect exposing
        ( ...
        , signInUser, signOutUser
        )

    signInUser : User -> Effect msg
    signInUser user =
        sendSharedMsg (Shared.Msg.SignInUser user)

    signOutUser : Effect msg
    signOutUser =
        sendSharedMsg Shared.Msg.SignOutUser

This makes it easy to use in a page:

    module Pages.SignIn exposing (Model, Msg, page)


    update : Msg -> Model -> ( Model, Effect Msg )
    update msg model =
        case msg of
            ...

            ApiResponded (Ok user) ->
                ( model
                , Effect.signInUser user
                )

            ...

Compare that with the generic alternative, which is more cumbersome to use and
allows _any_ `Shared.Msg` to be called from any page, even if that isn't desired.

    module Pages.SignIn exposing (Model, Msg, page)


    update : Msg -> Model -> ( Model, Effect Msg )
    update msg model =
        case msg of
            ...

            ApiResponded (Ok user) ->
                ( model
                , Effect.sendSharedMsg (Shared.Msg.SignInUser user)
                )

            ...

-}
sendSharedMsg : Shared.Msg.Msg -> Effect msg
sendSharedMsg =
    SendSharedMsg



-- INTERNALS


{-| Elm Land depends on this function to connect pages and layouts
together into your overall app.
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

        SendSharedMsg sharedMsg ->
            SendSharedMsg sharedMsg


{-| Elm Land depends on this function to actually perform your Effects.

Note that the incoming `Effect msg` is **not** `Effect mainMsg`, so you'll need to
use the provided `options.fromMsg` before returning `Cmd mainMsg`

-}
toCmd :
    { key : Browser.Navigation.Key
    , url : Url
    , shared : Shared.Model.Model
    , fromSharedMsg : Shared.Msg.Msg -> mainMsg
    , fromMsg : msg -> mainMsg
    , fromCmd : Cmd mainMsg -> mainMsg
    , toCmd : mainMsg -> Cmd mainMsg
    }
    -> Effect msg
    -> Cmd mainMsg
toCmd options effect =
    case effect of
        None ->
            Cmd.none

        Batch list ->
            Cmd.batch (List.map (toCmd options) list)

        SendCmd cmd ->
            Cmd.map options.fromMsg cmd

        PushUrl url ->
            Browser.Navigation.pushUrl options.key url

        ReplaceUrl url ->
            Browser.Navigation.replaceUrl options.key url

        LoadExternalUrl url ->
            Browser.Navigation.load url

        SendSharedMsg sharedMsg ->
            Task.succeed sharedMsg
                |> Task.perform options.fromSharedMsg
