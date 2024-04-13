module Auth exposing (User, onPageLoad, viewCustomPage)

import Auth.Action
import Dict
import Html
import Route exposing (Route)
import Route.Path
import Shared
import Shared.Model
import User
import View exposing (View)


type alias User =
    User.User


{-| Called before an auth-only page is loaded.
-}
onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.authStatus of
        Shared.Model.NotLoggedIn ->
            Auth.Action.loadCustomPage

        Shared.Model.LoggedInAs user ->
            Auth.Action.loadPageWithUser user

        Shared.Model.TokenExpired ->
            Auth.Action.loadCustomPage


{-| Renders whenever `Auth.Action.showCustomView` is returned from `onPageLoad`.
-}
viewCustomPage : Shared.Model -> Route () -> View Never
viewCustomPage shared route =
    case shared.authStatus of
        Shared.Model.NotLoggedIn ->
            { title = "Permission denied"
            , body = [ Html.text "You need to be logged in to see this!" ]
            }

        Shared.Model.LoggedInAs user ->
            { title = "Loading..."
            , body = []
            }

        Shared.Model.TokenExpired ->
            { title = "Token expired"
            , body = [ Html.text "Your token expired, here's an error page!" ]
            }
