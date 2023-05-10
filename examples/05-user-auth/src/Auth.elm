module Auth exposing (User, onPageLoad, viewLoadingPage)

import Auth.Action
import Dict
import Route exposing (Route)
import Route.Path
import Shared
import Shared.Model
import View exposing (View)


type alias User =
    Shared.Model.User


{-| Called before an auth-only page is loaded.
-}
onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.user of
        Just user ->
            Auth.Action.loadPageWithUser user

        Nothing ->
            Auth.Action.pushRoute
                { path = Route.Path.SignIn
                , query =
                    Dict.fromList
                        [ ( "from", route.url.path )
                        ]
                , hash = Nothing
                }


{-| Renders whenever `Auth.Action.showLoadingPage` is returned from `onPageLoad`.
-}
viewLoadingPage : Shared.Model -> Route () -> View Never
viewLoadingPage shared route =
    View.fromString "Loading..."
