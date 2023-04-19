module Page exposing
    ( Page, decoder
    , filepath
    , toAnnotationForPageFunction
    , isStatefulPage
    , isNotExposingPageFunction
    , isNotExposingModelType, isNotExposingMsgType
    , Problem(..), toProblem
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
    = Static
    | Stateful


toAnnotationForPageFunction : Page -> Maybe String
toAnnotationForPageFunction (Page page) =
    case findPageFunction page.file of
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


findPageFunction : Elm.Syntax.File.File -> Maybe Elm.Syntax.Expression.Function
findPageFunction file =
    let
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
    file.declarations
        |> List.map Elm.Syntax.Node.value
        |> List.filterMap toMaybeFunctionExpression
        |> List.filter (isFunctionWithName "page")
        |> List.head


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


type Problem
    = PageFunctionNotFound
    | PageFunctionMissingTypeAnnotation
    | PageFunctionExpectedTypeOrFunction
    | PageFunctionExpectedViewOrPageValue
    | PageFunctionExpectedFunctionReturningPage
    | PageFunctionExpectedRouteParams
    | PageFunctionExpectedSharedModel


toPageKind : Page -> Result Problem PageKind
toPageKind (Page page) =
    case findPageFunction page.file of
        Nothing ->
            Err PageFunctionNotFound

        Just { signature } ->
            let
                isAuthUser : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isAuthUser annotation =
                    case annotation of
                        Elm.Syntax.TypeAnnotation.Typed node [] ->
                            isModuleNamed "Auth.User" (toValue node)

                        _ ->
                            False

                isSharedModel : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isSharedModel annotation =
                    case annotation of
                        Elm.Syntax.TypeAnnotation.Typed node [] ->
                            isModuleNamed "Shared.Model" (toValue node)

                        _ ->
                            False

                isModuleNamed : String -> ( List String, String ) -> Bool
                isModuleNamed str ( xs, x ) =
                    String.split "." str == xs ++ [ x ]

                isGenericMsgType : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isGenericMsgType anno =
                    case anno of
                        Elm.Syntax.TypeAnnotation.GenericType "msg" ->
                            True

                        _ ->
                            False

                isModelAndMsg : List (Elm.Syntax.Node.Node Elm.Syntax.TypeAnnotation.TypeAnnotation) -> Bool
                isModelAndMsg nodes =
                    case List.map toValue nodes of
                        [ Elm.Syntax.TypeAnnotation.Typed modelVar _, Elm.Syntax.TypeAnnotation.Typed msgVar _ ] ->
                            isModuleNamed "Model" (toValue modelVar)
                                && isModuleNamed "Msg" (toValue msgVar)

                        _ ->
                            False

                toValue : Elm.Syntax.Node.Node value -> value
                toValue =
                    Elm.Syntax.Node.value

                isRouteWithParamsMatching : Filepath -> Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isRouteWithParamsMatching filepath_ annotation =
                    case annotation of
                        Elm.Syntax.TypeAnnotation.Typed node [ paramsArg ] ->
                            isModuleNamed "Route" (toValue node) && isValidParams filepath_ (toValue paramsArg)

                        _ ->
                            False

                isValidParams : Filepath -> Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isValidParams filepath_ params =
                    fromAnnotationToString params
                        == Filepath.toRouteParamsRecordString filepath_

                isViewMsg : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isViewMsg annotation =
                    case annotation of
                        Elm.Syntax.TypeAnnotation.Typed node vars ->
                            isModuleNamed "View" (toValue node)
                                && (List.head vars
                                        |> Maybe.map (toValue >> isGenericMsgType)
                                        |> Maybe.withDefault False
                                   )

                        _ ->
                            False

                isPageModelMsg : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
                isPageModelMsg annotation =
                    case annotation of
                        Elm.Syntax.TypeAnnotation.Typed node vars ->
                            isModuleNamed "Page" (toValue node) && isModelAndMsg vars

                        _ ->
                            False

                findSharedRoutePageFunction :
                    Elm.Syntax.TypeAnnotation.TypeAnnotation
                    -> Result Problem PageKind
                findSharedRoutePageFunction annotation =
                    case annotation of
                        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation left2 right2 ->
                            if isSharedModel (toValue left2) then
                                case toValue right2 of
                                    Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation left3 right3 ->
                                        if isRouteWithParamsMatching page.filepath (toValue left3) then
                                            case toValue right3 of
                                                Elm.Syntax.TypeAnnotation.Typed node vars ->
                                                    if isModuleNamed "Page" (toValue node) && isModelAndMsg vars then
                                                        Ok Stateful

                                                    else
                                                        Err PageFunctionExpectedViewOrPageValue

                                                _ ->
                                                    Err PageFunctionExpectedFunctionReturningPage

                                        else
                                            Err PageFunctionExpectedRouteParams

                                    _ ->
                                        Err PageFunctionExpectedRouteParams

                            else
                                Err PageFunctionExpectedSharedModel

                        _ ->
                            Err PageFunctionExpectedSharedModel
            in
            case signature |> Maybe.map (toValue >> .typeAnnotation >> toValue) of
                Nothing ->
                    Err PageFunctionMissingTypeAnnotation

                Just typeAnnotation ->
                    case typeAnnotation of
                        Elm.Syntax.TypeAnnotation.Typed node vars ->
                            if isViewMsg typeAnnotation then
                                Ok Static

                            else if isPageModelMsg typeAnnotation then
                                Ok Stateful

                            else
                                Err PageFunctionExpectedViewOrPageValue

                        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation left1 right1 ->
                            if isValidParams page.filepath (toValue left1) then
                                if isViewMsg (toValue right1) then
                                    Ok Static

                                else if isPageModelMsg (toValue right1) then
                                    Ok Stateful

                                else
                                    Err PageFunctionExpectedTypeOrFunction

                            else if isAuthUser (toValue left1) then
                                findSharedRoutePageFunction (toValue right1)

                            else
                                findSharedRoutePageFunction typeAnnotation

                        _ ->
                            Err PageFunctionExpectedTypeOrFunction


isStatefulPage : Page -> Bool
isStatefulPage page =
    toPageKind page == Ok Stateful


toProblem : Page -> Maybe Problem
toProblem page =
    case toPageKind page of
        Err problem ->
            Just problem

        Ok _ ->
            Nothing



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
