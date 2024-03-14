module Api.Queries.Characters.Character exposing 
    ( Character(..)
    , Human, Droid
    )

{-|

@docs Character
@docs Human, Droid

-}

import GraphQL.Scalar.Id


type Character
    = On_Human Human
    | On_Droid Droid


type alias Human =
    { id : GraphQL.Scalar.Id.Id
    , name : String
    , hasHair : Bool
    }


type alias Droid =
    { id : GraphQL.Scalar.Id.Id
    , name : String
    , primaryFunction : Maybe String
    }
