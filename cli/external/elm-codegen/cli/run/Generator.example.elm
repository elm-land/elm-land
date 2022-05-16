port module Generator exposing (onSuccess, onFailure)


import Json.Encode as Json


type alias File =
       { path : String
       , contents : String
       }

encodeFile : File -> Json.Value
encodeFile file =
   Encode.object
        [ ("path", (Json.string file.path))
        , ("contents", (Json.string file.contents))
        ]


onSuccess : List File -> Cmd msg
onSuccess files =
     onSuccessSend (List.map encodeFile)


onFailure : String -> Cmd msg
onFailure err =
     onFailureSend err



port onSuccessSend : List Json.Value -> Cmd msg


port onFailureSend : String -> Cmd msg


