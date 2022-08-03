module Auth exposing (User, onPageLoad)

import Auth.Action
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias User =
    Shared.User


onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.user of
        Just user ->
            Auth.Action.loadPageWithUser user

        Nothing ->
            Auth.Action.redirectToRoute
                { path = Route.Path.NotFound_
                , query = []
                , hash = Nothing
                }