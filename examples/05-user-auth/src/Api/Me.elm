module Api.Me exposing (User, get)

import Effect exposing (Effect)
import Http
import Json.Decode


type alias User =
    { id : String
    , name : String
    , profileImageUrl : String
    , email : String
    }


decoder : Json.Decode.Decoder User
decoder =
    Json.Decode.map4 User
        (Json.Decode.field "id" Json.Decode.string)
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "profileImageUrl" Json.Decode.string)
        (Json.Decode.field "email" Json.Decode.string)


get :
    { onResponse : Result Http.Error User -> msg
    , token : String
    }
    -> Effect msg
get options =
    let
        url : String
        url =
            "http://localhost:5000/api/me?token=" ++ options.token

        cmd : Cmd msg
        cmd =
            Http.get
                { url = url
                , expect = Http.expectJson options.onResponse decoder
                }
    in
    Effect.sendCmd cmd
