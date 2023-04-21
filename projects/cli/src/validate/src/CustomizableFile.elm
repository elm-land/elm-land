module CustomizableFile exposing
    ( CustomizableFile, decoder
    , isNotExposing
    , Problem(..), findProblemWithFunctionAnnotation
    , toAnnotationForFunction
    , filepath
    )

{-|

@docs CustomizableFile, decoder

@docs isNotExposing

@docs Problem, findProblemWithFunctionAnnotation

@docs toAnnotationForFunction

-}

import Elm.Parser
import Elm.Processing
import Elm.Syntax.File
import Extras.ElmSyntax
import Filepath exposing (Filepath)
import Json.Decode


type CustomizableFile
    = CustomizableFile Internals


type alias Internals =
    { filepath : Filepath
    , file : Elm.Syntax.File.File
    }


filepath : CustomizableFile -> Filepath
filepath (CustomizableFile file) =
    file.filepath


decoder : ( String, List String ) -> Json.Decode.Decoder CustomizableFile
decoder filepath_ =
    Json.Decode.map CustomizableFile
        (Json.Decode.map2 Internals
            (Json.Decode.succeed (Filepath.fromList filepath_))
            fileDecoder
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



-- EXPOSING LIST


isNotExposing : String -> CustomizableFile -> Bool
isNotExposing name (CustomizableFile file) =
    Extras.ElmSyntax.isNotExposing name file.file



-- PROBLEMS WITH TYPE ANNOTATIONS


type Problem
    = MissingTypeAnnotation
    | InvalidTypeAnnotation String


findProblemWithFunctionAnnotation :
    { name : String
    , expected : String
    , file : CustomizableFile
    }
    -> Maybe Problem
findProblemWithFunctionAnnotation { name, expected, file } =
    case toAnnotationForFunction name file of
        Nothing ->
            Just MissingTypeAnnotation

        Just actual ->
            if actual == expected then
                Nothing

            else
                Just (InvalidTypeAnnotation actual)


toAnnotationForFunction : String -> CustomizableFile -> Maybe String
toAnnotationForFunction functionName (CustomizableFile file) =
    Extras.ElmSyntax.toAnnotationForFunction
        functionName
        file.file
