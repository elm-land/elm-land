module Auth exposing (User, onPageLoad)

import Auth.Action
import Dict
import Route exposing (Route)
import Route.Path
import Shared
import View exposing (View)


type alias User =
    {}


onPageLoad : Shared.Model -> Route () -> Auth.Action.Action User
onPageLoad shared route =
    Auth.Action.pushRoute
        { path = Route.Path.NotFound_
        , query = Dict.empty
        , hash = Nothing
        }
