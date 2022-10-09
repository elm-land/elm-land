module GraphQL.Queries.FetchCurrentUser.UserResult exposing
    ( UserResult(..)
    , User, NotSignedIn
    )

{-|

@docs UserResult
@docs User, NotSignedIn

-}

import GraphQL.Scalar


type UserResult
    = OnUser User
    | OnNotSignedIn NotSignedIn


type alias User =
    { id : GraphQL.Scalar.ID
    , name : String
    , avatarUrl : Maybe String
    }


type alias NotSignedIn =
    { message : String
    }
