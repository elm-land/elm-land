module Page exposing
    ( Page, decoder
    , filepath
    , isNotExposingPageFunction
    )

{-|

@docs Page, decoder
@docs filepath

@docs isNotExposingPageFunction

-}

import Elm.Parser
import Elm.Processing
import Elm.RawFile
import Elm.Syntax.Exposing
import Elm.Syntax.File
import Elm.Syntax.Module
import Elm.Syntax.Node
import Filepath exposing (Filepath)
import Json.Decode


type Page
    = Page Internals


type alias Internals =
    { filepath : Filepath
    , file : Elm.Syntax.File.File
    }


filepath : Page -> Filepath
filepath (Page page) =
    page.filepath


decoder : Json.Decode.Decoder Page
decoder =
    Json.Decode.map Page
        (Json.Decode.map2 Internals
            (Json.Decode.field "filepath" (Filepath.decoder { folder = "Pages" }))
            (Json.Decode.field "contents" fileDecoder)
        )


fileDecoder : Json.Decode.Decoder Elm.Syntax.File.File
fileDecoder =
    let
        toMaybeFile : String -> Maybe Elm.Syntax.File.File
        toMaybeFile contents =
            contents
                |> Elm.Parser.parse
                |> Result.toMaybe
                |> Maybe.map (Elm.Processing.process Elm.Processing.init)
    in
    Json.Decode.string
        |> Json.Decode.andThen
            (\str ->
                case toMaybeFile str of
                    Just file ->
                        Json.Decode.succeed file

                    Nothing ->
                        Json.Decode.fail "Could not decode file"
            )


isNotExposingPageFunction : Page -> Bool
isNotExposingPageFunction (Page page) =
    let
        moduleDefinition : Elm.Syntax.Module.DefaultModuleData
        moduleDefinition =
            case Elm.Syntax.Node.value page.file.moduleDefinition of
                Elm.Syntax.Module.NormalModule data ->
                    data

                Elm.Syntax.Module.PortModule data ->
                    data

                Elm.Syntax.Module.EffectModule data ->
                    { moduleName = data.moduleName
                    , exposingList = data.exposingList
                    }

        exposingList : Elm.Syntax.Exposing.Exposing
        exposingList =
            Elm.Syntax.Node.value moduleDefinition.exposingList
    in
    case exposingList of
        Elm.Syntax.Exposing.All _ ->
            False

        Elm.Syntax.Exposing.Explicit nodes ->
            let
                topLevelExposeList : List String
                topLevelExposeList =
                    nodes
                        |> List.map
                            (\node ->
                                case Elm.Syntax.Node.value node of
                                    Elm.Syntax.Exposing.InfixExpose name ->
                                        name

                                    Elm.Syntax.Exposing.FunctionExpose name ->
                                        name

                                    Elm.Syntax.Exposing.TypeOrAliasExpose name ->
                                        name

                                    Elm.Syntax.Exposing.TypeExpose { name } ->
                                        name
                            )
            in
            topLevelExposeList
                |> List.member "page"
                |> not
