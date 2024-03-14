module Api.Internals.Input exposing (..)

import Dict exposing (Dict)
import GraphQL.Encode


type NestedForm missing
    = NestedForm (Dict String GraphQL.Encode.Value)


type UserSignInForm missing
    = UserSignInForm (Dict String GraphQL.Encode.Value)
