module PageFile exposing
    ( PageFile
    , decoder
    , isElmLandPage
    , toFilepath
    , toLayoutName
    )

import Elm.Parser
import Elm.Processing
import Elm.RawFile
import Elm.Syntax.Declaration
import Elm.Syntax.Exposing
import Elm.Syntax.Expression
import Elm.Syntax.File
import Elm.Syntax.Module
import Elm.Syntax.ModuleName
import Elm.Syntax.Node
import Elm.Syntax.Signature
import Elm.Syntax.TypeAnnotation
import Filepath exposing (Filepath)
import Json.Decode


type PageFile
    = PageFile Internals


type alias Internals =
    { filepath : Filepath
    , contents : String
    }


decoder : Json.Decode.Decoder PageFile
decoder =
    Json.Decode.map PageFile
        (Json.Decode.map2 Internals
            (Json.Decode.field "filepath" Filepath.decoder)
            (Json.Decode.field "contents" Json.Decode.string)
        )


toFilepath : PageFile -> Filepath
toFilepath (PageFile { filepath }) =
    filepath


toLayoutName : PageFile -> Maybe String
toLayoutName (PageFile { contents }) =
    let
        toLayoutNameFromFile : Elm.Syntax.File.File -> Maybe String
        toLayoutNameFromFile file =
            file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.filterMap toLayoutNameFromDeclaration
                |> List.head

        toLayoutNameFromDeclaration : Elm.Syntax.Declaration.Declaration -> Maybe String
        toLayoutNameFromDeclaration decl =
            case decl of
                Elm.Syntax.Declaration.FunctionDeclaration func ->
                    toLayoutNameFromFunction func

                _ ->
                    Nothing

        toLayoutNameFromFunction : Elm.Syntax.Expression.Function -> Maybe String
        toLayoutNameFromFunction func =
            let
                functionName : String
                functionName =
                    func.declaration
                        |> Elm.Syntax.Node.value
                        |> .name
                        |> Elm.Syntax.Node.value

                expression : Elm.Syntax.Expression.Expression
                expression =
                    Elm.Syntax.Node.value (Elm.Syntax.Node.value func.declaration).expression
            in
            if functionName == "layout" then
                case expression of
                    Elm.Syntax.Expression.FunctionOrValue [ "ElmLand", "Layout" ] name ->
                        Just name

                    _ ->
                        Nothing

            else
                Nothing
    in
    contents
        |> Elm.Parser.parse
        |> Result.map (Elm.Processing.process Elm.Processing.init)
        |> Result.toMaybe
        |> Maybe.andThen toLayoutNameFromFile


isElmLandPage : PageFile -> Bool
isElmLandPage (PageFile { contents }) =
    let
        isElmLandPageFromFile : Elm.Syntax.File.File -> Bool
        isElmLandPageFromFile file =
            file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.any isElmLandPageFromDeclaration

        isElmLandPageFromDeclaration : Elm.Syntax.Declaration.Declaration -> Bool
        isElmLandPageFromDeclaration decl =
            case decl of
                Elm.Syntax.Declaration.FunctionDeclaration func ->
                    isElmLandPageFromFunction func

                _ ->
                    False

        isElmLandPageFromFunction : Elm.Syntax.Expression.Function -> Bool
        isElmLandPageFromFunction func =
            let
                functionName : String
                functionName =
                    func.declaration
                        |> Elm.Syntax.Node.value
                        |> .name
                        |> Elm.Syntax.Node.value

                expression : Elm.Syntax.Expression.Expression
                expression =
                    Elm.Syntax.Node.value (Elm.Syntax.Node.value func.declaration).expression
            in
            if functionName == "page" then
                case expression of
                    Elm.Syntax.Expression.Application (node :: _) ->
                        case Elm.Syntax.Node.value node of
                            Elm.Syntax.Expression.FunctionOrValue [ "ElmLand", "Page" ] _ ->
                                True

                            _ ->
                                False

                    _ ->
                        False

            else
                False
    in
    contents
        |> Elm.Parser.parse
        |> Result.map (Elm.Processing.process Elm.Processing.init)
        |> Result.toMaybe
        |> Maybe.map isElmLandPageFromFile
        |> Maybe.withDefault False
