module Auth exposing (User, onPageLoad)

import Auth.Action
import Dict
import Domain.User
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias User =
    Domain.User.User


onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    case shared.user of
        Just user ->
            Auth.Action.loadPageWithUser user

        Nothing ->
            Auth.Action.pushRoute
                { path = Route.Path.SignIn
                , query = Dict.empty
                , hash = Nothing
                }
