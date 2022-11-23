module Shared.Msg exposing (Msg(..))

import Domain.User
import Http


type Msg
    = ApiMeResponded (Result Http.Error Domain.User.User)
    | SignInPageSignedInUser (Result Http.Error Domain.User.User)
    | PageSignedOutUser
