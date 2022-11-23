module Shared.Model exposing (Model)

import Domain.SignInStatus


type alias Model =
    { signInStatus : Domain.SignInStatus.SignInStatus
    }
