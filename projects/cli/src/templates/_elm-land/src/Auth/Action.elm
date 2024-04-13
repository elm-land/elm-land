module Auth.Action exposing
    ( Action(..)
    , loadPageWithUser, loadCustomPage
    , replaceRoute, pushRoute, loadExternalUrl
    , view, subscriptions, command
    )

{-|

@docs Action
@docs loadPageWithUser, loadCustomPage
@docs replaceRoute, pushRoute, loadExternalUrl

@docs view, subscriptions, command

-}

import Browser.Navigation
import Dict exposing (Dict)
import Route.Path
import Shared
import Url exposing (Url)
import View exposing (View)


{-| Describes the action to take for authenticated pages, based
on the current `Route` and `Shared.Model`
-}
type Action user
    = LoadPageWithUser user
    | LoadCustomPage
    | ReplaceRoute
        { path : Route.Path.Path
        , query : Dict String String
        , hash : Maybe String
        }
    | PushRoute
        { path : Route.Path.Path
        , query : Dict String String
        , hash : Maybe String
        }
    | LoadExternalUrl String


{-| Successfully pass the user along to the authenticated page.
-}
loadPageWithUser : user -> Action user
loadPageWithUser =
    LoadPageWithUser


{-| Rather than navigating to a different route, keep the URL, but render
what was defined in `Auth.loadCustomPage`.

**Note:** `Auth.loadCustomPage` has access to the `Shared.Model`, so you
can render different pages in different authentication scenarios.

-}
loadCustomPage : Action user
loadCustomPage =
    LoadCustomPage


{-| Replace the URL with the provided route.
-}
replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Action user
replaceRoute =
    ReplaceRoute


{-| Push a new URL with the provided route.
-}
pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Action user
pushRoute =
    PushRoute


{-| Navigate to a URL for an external website.
-}
loadExternalUrl : String -> Action user
loadExternalUrl =
    LoadExternalUrl



-- USED INTERNALLY BY ELM LAND


view : View msg -> (user -> View msg) -> Action user -> View msg
view viewCustomPage viewPageWithUser authAction =
    case authAction of
        LoadPageWithUser user ->
            viewPageWithUser user

        LoadCustomPage ->
            viewCustomPage

        ReplaceRoute _ ->
            View.none

        PushRoute _ ->
            View.none

        LoadExternalUrl _ ->
            View.none


subscriptions : (user -> Sub msg) -> Action user -> Sub msg
subscriptions toSub authAction =
    case authAction of
        LoadPageWithUser user ->
            toSub user

        LoadCustomPage ->
            Sub.none

        ReplaceRoute _ ->
            Sub.none

        PushRoute _ ->
            Sub.none

        LoadExternalUrl _ ->
            Sub.none


command : (user -> Cmd msg) -> Action user -> Cmd msg
command toCmd authAction =
    case authAction of
        LoadPageWithUser user ->
            toCmd user

        LoadCustomPage ->
            Cmd.none

        ReplaceRoute _ ->
            Cmd.none

        PushRoute _ ->
            Cmd.none

        LoadExternalUrl _ ->
            Cmd.none
