module GraphQL.Http.Response exposing (Response(..))

import GraphQL.Http.Error


type Response data
    = Loading
    | Success data
    | Failure GraphQL.Http.Error.Error