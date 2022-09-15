module Auth.Action exposing
    ( Action(..)
    , loadPageWithUser, pushRoute, replaceRoute, showLoadingPage
    , view, subscriptions
    )

{-|

@docs Action
@docs loadPageWithUser, pushRoute, replaceRoute, showLoadingPage

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
    | ExternalRedirect String
    | ShowLoadingPage (View Never)


loadPageWithUser : user -> Action user
loadPageWithUser =
    LoadPageWithUser


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


externalRedirect : String -> Action user
externalRedirect =
    ExternalRedirect


showLoadingPage : View Never -> Action user
showLoadingPage =
    ShowLoadingPage


view : (user -> View msg) -> Action user -> View msg
view toView authAction =
    case authAction of
        LoadPageWithUser user ->
            toView user

        ReplaceRoute _ ->
            View.none

        PushRoute _ ->
            View.none

        ExternalRedirect _ ->
            View.none

        ShowLoadingPage loadingView ->
            View.map never loadingView


subscriptions : (user -> Sub msg) -> Action user -> Sub msg
subscriptions toView authAction =
    case authAction of
        LoadPageWithUser user ->
            toView user

        ReplaceRoute _ ->
            Sub.none

        PushRoute _ ->
            Sub.none

        ExternalRedirect _ ->
            Sub.none

        ShowLoadingPage _ ->
            Sub.none
