module Layout exposing
    ( Layout, decoder
    , filepath
    , isNotExposingLayoutFunction
    , isNotExposingPropsType, isNotExposingModelType, isNotExposingMsgType
    , Problem(..), toProblem
    , toAnnotationForLayoutFunction
    , toValidLayoutFunctionAnnotations
    )

{-|

@docs Layout, decoder
@docs filepath

@docs isNotExposingLayoutFunction
@docs isNotExposingPropsType, isNotExposingModelType, isNotExposingMsgType

@docs Problem, toProblem
@docs toAnnotationForLayoutFunction
@docs toValidLayoutFunctionAnnotations

-}

import Elm.Parser
import Elm.Processing
import Elm.Syntax.File
import Extras.ElmSyntax
import Filepath exposing (Filepath)
import Json.Decode


type Layout
    = Layout Internals


type alias Internals =
    { filepath : Filepath
    , file : Elm.Syntax.File.File
    }


filepath : Layout -> Filepath
filepath (Layout layout) =
    layout.filepath


decoder : Json.Decode.Decoder Layout
decoder =
    Json.Decode.map Layout
        (Json.Decode.map2 Internals
            (Json.Decode.field "filepath" (Filepath.decoder { folder = "Layouts" }))
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



-- EXPOSING LIST


isNotExposingLayoutFunction : Layout -> Bool
isNotExposingLayoutFunction (Layout layout) =
    Extras.ElmSyntax.isNotExposing "layout" layout.file


isNotExposingModelType : Layout -> Bool
isNotExposingModelType (Layout layout) =
    Extras.ElmSyntax.isNotExposing "Model" layout.file


isNotExposingPropsType : Layout -> Bool
isNotExposingPropsType (Layout layout) =
    Extras.ElmSyntax.isNotExposing "Props" layout.file


isNotExposingMsgType : Layout -> Bool
isNotExposingMsgType (Layout layout) =
    Extras.ElmSyntax.isNotExposing "Msg" layout.file



-- PROBLEMS WITH TYPE ANNOTATIONS


type Problem
    = MissingTypeAnnotation
    | InvalidTypeAnnotation


toProblem : Layout -> Maybe Problem
toProblem layout =
    let
        validAnnotations : List String
        validAnnotations =
            Filepath.toParentLayoutModuleName (filepath layout)
                |> toValidLayoutFunctionAnnotations
    in
    case toAnnotationForLayoutFunction layout of
        Nothing ->
            Just MissingTypeAnnotation

        Just str ->
            if List.member str validAnnotations then
                Nothing

            else
                Just InvalidTypeAnnotation


toAnnotationForLayoutFunction : Layout -> Maybe String
toAnnotationForLayoutFunction (Layout layout) =
    Extras.ElmSyntax.toAnnotationForFunction "layout" layout.file


toValidLayoutFunctionAnnotations : Maybe String -> List String
toValidLayoutFunctionAnnotations parentLayoutModuleName =
    let
        parentPropsWithoutContentMsg : String
        parentPropsWithoutContentMsg =
            case parentLayoutModuleName of
                Just str ->
                    str ++ ".Props"

                Nothing ->
                    "()"

        parentPropsWithContentMsg : String
        parentPropsWithContentMsg =
            case parentLayoutModuleName of
                Just str ->
                    "(" ++ str ++ ".Props contentMsg)"

                Nothing ->
                    "()"
    in
    List.concatMap
        (\parentProps ->
            [ "Props -> Shared.Model -> Route () -> Layout ${parentProps} Model Msg contentMsg"
                |> String.replace "${parentProps}" parentProps
            , "Props contentMsg -> Shared.Model -> Route () -> Layout ${parentProps} Model Msg contentMsg"
                |> String.replace "${parentProps}" parentProps
            ]
        )
        [ parentPropsWithoutContentMsg, parentPropsWithContentMsg ]
