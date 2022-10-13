module Auth.Action exposing
    ( Action(..)
    , loadPageWithUser, showLoadingPage
    , replaceRoute, pushRoute, loadExternalUrl
    , view, subscriptions
    )

{-|

@docs Action
@docs loadPageWithUser, showLoadingPage
@docs replaceRoute, pushRoute, loadExternalUrl

@docs view, subscriptions

-}

import Browser.Navigation
import Dict exposing (Dict)
import Route.Path
import Shared
import Url exposing (Url)
import View exposing (View)


type Action user
    = LoadPageWithUser user
    | ShowLoadingPage (View Never)
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


loadPageWithUser : user -> Action user
loadPageWithUser =
    LoadPageWithUser


showLoadingPage : View Never -> Action user
showLoadingPage =
    ShowLoadingPage


replaceRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Action user
replaceRoute =
    ReplaceRoute


pushRoute :
    { path : Route.Path.Path
    , query : Dict String String
    , hash : Maybe String
    }
    -> Action user
pushRoute =
    PushRoute


loadExternalUrl : String -> Action user
loadExternalUrl =
    LoadExternalUrl


view : (user -> View msg) -> Action user -> View msg
view toView authAction =
    case authAction of
        LoadPageWithUser user ->
            toView user

        ShowLoadingPage loadingView ->
            View.map never loadingView

        ReplaceRoute _ ->
            View.none

        PushRoute _ ->
            View.none

        LoadExternalUrl _ ->
            View.none


subscriptions : (user -> Sub msg) -> Action user -> Sub msg
subscriptions toView authAction =
    case authAction of
        LoadPageWithUser user ->
            toView user

        ShowLoadingPage _ ->
            Sub.none

        ReplaceRoute _ ->
            Sub.none

        PushRoute _ ->
            Sub.none

        LoadExternalUrl _ ->
            Sub.none
