module Command exposing (Command, fromJson, run)

import Commands.AddPage
import Commands.Generate
import Json.Decode
import RoutePath exposing (RoutePath)


type Command
    = AddPage Commands.AddPage.Options
    | Generate Commands.Generate.Options



-- RUNNING THE COMMAND


run : Command -> Cmd msg
run command =
    case command of
        AddPage options ->
            Commands.AddPage.run options

        Generate options ->
            Commands.Generate.run options



-- DECODING FROM NODE.JS


fromJson : Json.Decode.Value -> Result Json.Decode.Error Command
fromJson json =
    json
        |> Json.Decode.decodeValue decoder


decoder : Json.Decode.Decoder Command
decoder =
    Json.Decode.oneOf
        [ withTag "add-page" addPageDecoder
            |> Json.Decode.map AddPage
        , withTag "generate-elm-land-files" generateDecoder
            |> Json.Decode.map Generate
        ]


withTag : String -> Json.Decode.Decoder value -> Json.Decode.Decoder value
withTag expectedTag decoderForThatTag =
    Json.Decode.field "tag" Json.Decode.string
        |> Json.Decode.andThen
            (\actualTag ->
                if actualTag == expectedTag then
                    Json.Decode.field "data" decoderForThatTag

                else
                    Json.Decode.fail ("Did not recognize tag: " ++ actualTag)
            )


addPageDecoder : Json.Decode.Decoder Commands.AddPage.Options
addPageDecoder =
    Json.Decode.map2 Commands.AddPage.Options
        (Json.Decode.field "routePath" RoutePath.decoder)
        (Json.Decode.field "url" Json.Decode.string)


generateDecoder : Json.Decode.Decoder Commands.Generate.Options
generateDecoder =
    Json.Decode.map Commands.Generate.Options
        (Json.Decode.field "pageRoutePaths" (Json.Decode.list RoutePath.decoder))


