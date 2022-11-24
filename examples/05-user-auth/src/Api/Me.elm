module Api.Me exposing (get)

import Domain.User
import Effect exposing (Effect)
import Http
import Json.Decode


get :
    { token : String
    , onResponse : Result Http.Error Domain.User.User -> msg
    }
    -> Effect msg
get { token, onResponse } =
    Effect.sendCmd
        (Http.get
            { url = "http://localhost:5000/api/me?token=" ++ token
            , expect = Http.expectJson onResponse userDecoder
            }
        )


userDecoder : Json.Decode.Decoder Domain.User.User
userDecoder =
    Json.Decode.map4 Domain.User.User
        (Json.Decode.field "id" Json.Decode.int)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "profileImageUrl" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)
