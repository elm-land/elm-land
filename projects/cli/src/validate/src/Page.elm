module Page exposing
    ( Page, decoder
    , filepath
    , toAnnotationForPageFunction
    , isUnknownPage, isInvalidPage, isStatefulPage
    , isNotExposingPageFunction
    , isNotExposingModelType, isNotExposingMsgType
    )

{-|

@docs Page, decoder
@docs filepath

@docs toAnnotationForPageFunction
@docs isUnknownPage, isInvalidPage, isStatefulPage

@docs isNotExposingPageFunction
@docs isNotExposingModelType, isNotExposingMsgType

-}

import Elm.Parser
import Elm.Processing
import Elm.RawFile
import Elm.Syntax.Declaration
import Elm.Syntax.Exposing
import Elm.Syntax.Expression
import Elm.Syntax.File
import Elm.Syntax.Module
import Elm.Syntax.Node
import Elm.Syntax.Signature
import Elm.Syntax.TypeAnnotation
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



-- PAGE KIND


type PageKind
    = Unknown
    | Invalid
    | Static
    | Stateful


toAnnotationForPageFunction : Page -> Maybe String
toAnnotationForPageFunction (Page page) =
    let
        pageFunction : Maybe Elm.Syntax.Expression.Function
        pageFunction =
            page.file.declarations
                |> List.map Elm.Syntax.Node.value
                |> List.filterMap toMaybeFunctionExpression
                |> List.filter (isFunctionWithName "page")
                |> List.head

        toMaybeFunctionExpression : Elm.Syntax.Declaration.Declaration -> Maybe Elm.Syntax.Expression.Function
        toMaybeFunctionExpression declaration =
            case declaration of
                Elm.Syntax.Declaration.FunctionDeclaration function ->
                    Just function

                _ ->
                    Nothing

        isFunctionWithName : String -> Elm.Syntax.Expression.Function -> Bool
        isFunctionWithName targetName function =
            function.declaration
                |> Elm.Syntax.Node.value
                |> .name
                |> Elm.Syntax.Node.value
                |> (==) targetName
    in
    case pageFunction of
        Just function ->
            case function.signature of
                Just node ->
                    let
                        signature : Elm.Syntax.Signature.Signature
                        signature =
                            Elm.Syntax.Node.value node

                        typeAnnotation : Elm.Syntax.TypeAnnotation.TypeAnnotation
                        typeAnnotation =
                            Elm.Syntax.Node.value signature.typeAnnotation
                    in
                    Just (fromAnnotationToString typeAnnotation)

                Nothing ->
                    Nothing

        Nothing ->
            Nothing


fromAnnotationToString : Elm.Syntax.TypeAnnotation.TypeAnnotation -> String
fromAnnotationToString typeAnnotation =
    case typeAnnotation of
        Elm.Syntax.TypeAnnotation.GenericType varName ->
            varName

        Elm.Syntax.TypeAnnotation.Typed firstNode [] ->
            fromModuleNodeToString firstNode

        Elm.Syntax.TypeAnnotation.Typed firstNode [ otherNode ] ->
            String.join " "
                [ fromModuleNodeToString firstNode
                , fromAnnotationToString (Elm.Syntax.Node.value otherNode)
                ]

        Elm.Syntax.TypeAnnotation.Typed firstNode restOfNodes ->
            String.join " "
                (fromModuleNodeToString firstNode
                    :: List.map (fromAnnotationToString << Elm.Syntax.Node.value) restOfNodes
                )

        Elm.Syntax.TypeAnnotation.Unit ->
            "()"

        Elm.Syntax.TypeAnnotation.Tupled [] ->
            "()"

        Elm.Syntax.TypeAnnotation.Tupled list ->
            "( " ++ String.join "," (List.map (fromAnnotationToString << Elm.Syntax.Node.value) list) ++ " )"

        Elm.Syntax.TypeAnnotation.Record [] ->
            "{}"

        Elm.Syntax.TypeAnnotation.Record recordFieldNodes ->
            "{ "
                ++ (recordFieldNodes
                        |> List.map Elm.Syntax.Node.value
                        |> List.map fromRecordFieldToString
                        |> String.join ", "
                   )
                ++ " }"

        Elm.Syntax.TypeAnnotation.GenericRecord varNameNode recordDefinitionNode ->
            case Elm.Syntax.Node.value recordDefinitionNode of
                [] ->
                    "{}"

                recordFieldNodes ->
                    "{ "
                        ++ Elm.Syntax.Node.value varNameNode
                        ++ " "
                        ++ (recordFieldNodes
                                |> List.map Elm.Syntax.Node.value
                                |> List.map fromRecordFieldToString
                                |> String.join ", "
                           )
                        ++ " }"

        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation inputNode outputNode ->
            String.join " -> "
                [ (fromAnnotationToString << Elm.Syntax.Node.value) inputNode
                , (fromAnnotationToString << Elm.Syntax.Node.value) outputNode
                ]


fromModuleNodeToString : Elm.Syntax.Node.Node ( List String, String ) -> String
fromModuleNodeToString node =
    case Elm.Syntax.Node.value node of
        ( list, str ) ->
            String.join "." (list ++ [ str ])


fromRecordFieldToString : Elm.Syntax.TypeAnnotation.RecordField -> String
fromRecordFieldToString recordField =
    case recordField of
        ( keyNode, valueNode ) ->
            String.join " : "
                [ Elm.Syntax.Node.value keyNode
                , (fromAnnotationToString << Elm.Syntax.Node.value) valueNode
                ]


toPageKind : Page -> PageKind
toPageKind page =
    case toAnnotationForPageFunction page of
        Nothing ->
            Unknown

        Just "View msg" ->
            Static

        Just "Page Model Msg" ->
            Stateful

        Just "Shared.Model -> Route () -> Page Model Msg" ->
            Stateful

        Just "Auth.User -> Shared.Model -> Route () -> Page Model Msg" ->
            Stateful

        Just _ ->
            Invalid


isUnknownPage : Page -> Bool
isUnknownPage page =
    toPageKind page == Unknown


isInvalidPage : Page -> Bool
isInvalidPage page =
    toPageKind page == Invalid


isStatefulPage : Page -> Bool
isStatefulPage page =
    toPageKind page == Stateful



-- EXPOSING LIST


isNotExposingPageFunction : Page -> Bool
isNotExposingPageFunction page =
    isNotExposing "page" page


isNotExposingModelType : Page -> Bool
isNotExposingModelType page =
    isNotExposing "Model" page


isNotExposingMsgType : Page -> Bool
isNotExposingMsgType page =
    isNotExposing "Msg" page


isNotExposing : String -> Page -> Bool
isNotExposing targetName (Page page) =
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
                        |> List.map toName

                toName : Elm.Syntax.Node.Node Elm.Syntax.Exposing.TopLevelExpose -> String
                toName node =
                    case Elm.Syntax.Node.value node of
                        Elm.Syntax.Exposing.InfixExpose name ->
                            name

                        Elm.Syntax.Exposing.FunctionExpose name ->
                            name

                        Elm.Syntax.Exposing.TypeOrAliasExpose name ->
                            name

                        Elm.Syntax.Exposing.TypeExpose { name } ->
                            name
            in
            topLevelExposeList
                |> List.member targetName
                |> not
