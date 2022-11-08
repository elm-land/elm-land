module Shared.Model exposing (Model)

import Domain.User


type alias Model =
    { user : Maybe Domain.User.User
    }
