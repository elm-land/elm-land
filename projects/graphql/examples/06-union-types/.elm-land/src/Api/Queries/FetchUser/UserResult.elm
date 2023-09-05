module Api.Queries.FetchUser.UserResult exposing 
    ( UserResult(..)
    , User, NotSignedIn
    )

{-|

@docs UserResult
@docs User, NotSignedIn

-}

import GraphQL.Scalar.Id


type UserResult
    = On_User User
    | On_NotSignedIn NotSignedIn


type alias User =
    { id : GraphQL.Scalar.Id.Id
    , username : String
    , avatarUrl : Maybe String
    }


type alias NotSignedIn =
    { message : String
    }
