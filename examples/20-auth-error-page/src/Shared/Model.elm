module Shared.Model exposing (AuthStatus(..), Model)

import User exposing (User)


type alias Model =
    { authStatus : AuthStatus
    }


type AuthStatus
    = NotLoggedIn
    | LoggedInAs User
    | TokenExpired
