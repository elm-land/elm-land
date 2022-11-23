module Domain.SignInStatus exposing (SignInStatus(..))

import Domain.User
import Http


type SignInStatus
    = NotSignedIn
    | SignedInWithToken String
    | SignedInWithUser Domain.User.User
    | FailedToSignIn Http.Error
