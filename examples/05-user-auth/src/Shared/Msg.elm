module Shared.Msg exposing (Msg(..))

import Api.User
import Http


type Msg
    = UserApiResponded (Result Http.Error Api.User.User)
    | SignInPageSignedInUser (Result Http.Error Api.User.User)
    | PageSignedOutUser
