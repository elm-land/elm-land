module Extras.ElmSyntax exposing
    ( findFunction
    , fromAnnotationToString
    , isNotExposing
    , toAnnotationForFunction
    )

import Elm.Syntax.Declaration
import Elm.Syntax.Exposing
import Elm.Syntax.Expression
import Elm.Syntax.File
import Elm.Syntax.Module
import Elm.Syntax.Node
import Elm.Syntax.Signature
import Elm.Syntax.TypeAnnotation


{-| Return True if the specified type or function is not exposed from this file.

    isNotExposing "Model" file == True

    isNotExposing "Msg" file == False

-}
isNotExposing : String -> Elm.Syntax.File.File -> Bool
isNotExposing targetName file =
    let
        moduleDefinition : Elm.Syntax.Module.DefaultModuleData
        moduleDefinition =
            case Elm.Syntax.Node.value file.moduleDefinition of
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


{-| Get the annotation for a function in a file
-}
toAnnotationForFunction : String -> Elm.Syntax.File.File -> Maybe String
toAnnotationForFunction functionName file =
    case findFunction functionName file of
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


findFunction : String -> Elm.Syntax.File.File -> Maybe Elm.Syntax.Expression.Function
findFunction functionName file =
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
        |> List.filter (isFunctionWithName functionName)
        |> List.head


fromAnnotationToString : Elm.Syntax.TypeAnnotation.TypeAnnotation -> String
fromAnnotationToString typeAnnotation =
    fromAnnotationToStringHelper False typeAnnotation


fromAnnotationToStringHelper : Bool -> Elm.Syntax.TypeAnnotation.TypeAnnotation -> String
fromAnnotationToStringHelper needsParens typeAnnotation =
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
            "( " ++ String.join ", " (List.map (fromAnnotationToString << Elm.Syntax.Node.value) list) ++ " )"

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
            let
                left =
                    Elm.Syntax.Node.value inputNode
            in
            String.join " -> "
                [ if isFunctionAnnotation left then
                    "(" ++ fromAnnotationToString left ++ ")"

                  else
                    fromAnnotationToString left
                , fromAnnotationToString (Elm.Syntax.Node.value outputNode)
                ]


isFunctionAnnotation : Elm.Syntax.TypeAnnotation.TypeAnnotation -> Bool
isFunctionAnnotation anno =
    case anno of
        Elm.Syntax.TypeAnnotation.FunctionTypeAnnotation _ _ ->
            True

        _ ->
            False


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
