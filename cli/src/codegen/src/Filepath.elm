module Filepath exposing
    ( Filepath
    , decoder
    , hasDynamicParameters
    , toList
    , toParamsRecord
    )

import CodeGen
import CodeGen.Annotation
import Json.Decode
import Extras.String


type Filepath
    = Filepath (List String)


decoder : Json.Decode.Decoder Filepath
decoder =
    Json.Decode.map Filepath
        (Json.Decode.list Json.Decode.string)


hasDynamicParameters : Filepath -> Bool
hasDynamicParameters (Filepath list) =
    case list of
        [ "Home_" ] ->
            False

        [ "NotFound_" ] ->
            False

        _ ->
            List.any (String.endsWith "_") list


toList : Filepath -> List String
toList (Filepath list) =
    list


toParamsRecord : Filepath -> CodeGen.Annotation
toParamsRecord (Filepath list) =
    list
        |> List.filter (String.endsWith "_")
        |> List.map (String.dropRight 1)
        |> List.map Extras.String.fromPascalCaseToCamelCase
        |> List.map (\fieldName -> ( fieldName, CodeGen.Annotation.string ))
        |> CodeGen.Annotation.record

