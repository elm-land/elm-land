module Api.Internals.Input exposing (..)

import Dict exposing (Dict)
import GraphQL.Encode


type UserSignInForm missing
    = UserSignInForm (Dict String GraphQL.Encode.Value)
