module GraphQL.Http.Error exposing (Error(..), Response, toUserFriendlyMessage)

import Dict exposing (Dict)
import Json.Decode


type Error
    = BadUrl String
    | Timeout
    | NetworkError
    | BadStatus Response
    | UnexpectedJson Response Json.Decode.Error


type alias Response =
    { url : String
    , statusCode : Int
    , statusText : String
    , headers : Dict String String
    , body : String
    }


toUserFriendlyMessage : Error -> String
toUserFriendlyMessage error =
    case error of
        BadUrl url ->
            "The request had an unexpected URL."

        Timeout ->
            "The request timed out."

        NetworkError ->
            "Connection failed. Are you offline?"

        BadStatus response ->
            "System provided an unexpected error (" ++ String.fromInt response.statusCode ++ ")."

        UnexpectedJson response jsonDecodeError ->
            "System provided unexpected data (" ++ String.fromInt response.statusCode ++ ")."
