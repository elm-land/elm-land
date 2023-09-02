module GraphQL.Introspection.Document exposing
    ( Document, decoder
    , toName, toContents
    , toVariables, hasVariables
    , FragmentDefinition, findFragmentDefinitionWithName
    , FragmentSpreadSelection
    , VariableDefinition
    , Selection(..), toRootSelections
    , FieldSelection, getNestedFields, toFieldSelections
    )

{-| These decoders were translated from the official `graphql`
NPM package's `node_modules/graphql/language/ast.d.ts` file.

(It uses the `DocumentNode` type)


## Document

@docs Document, decoder

@docs toName, toContents
@docs toVariables, hasVariables


## Fragments

@docs FragmentDefinition, findFragmentDefinitionWithName
@docs FragmentSpreadSelection


## Selection

@docs VariableDefinition
@docs Selection, toRootSelections

-}

import GraphQL.CliError exposing (CliError(..))
import GraphQL.Introspection.Document.VariableDefinition
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import GraphQL.Introspection.Schema.TypeRef as TypeRef exposing (TypeRef)
import Json.Decode
import List.Extra
import String.Extra


type Document
    = Document Internals


decoder : Json.Decode.Decoder Document
decoder =
    Json.Decode.map Document internalsDecoder


toName : Document -> String
toName (Document doc) =
    doc.filename
        |> String.split "."
        |> List.head
        |> Maybe.withDefault doc.filename


toContents : Document -> String
toContents (Document doc) =
    doc.contents



-- OPERATIONS


toRootOperation : Document -> Result CliError OperationDefinition
toRootOperation (Document doc) =
    let
        operationsDefinedInDocument : List OperationDefinition
        operationsDefinedInDocument =
            doc.definitions
                |> List.filterMap toOperationDefinition
    in
    case operationsDefinedInDocument of
        theOnlyOne :: [] ->
            -- If there's only one operation defined in this document,
            -- assume we're talking about that one
            Ok theOnlyOne

        _ ->
            operationsDefinedInDocument
                |> List.Extra.find
                    (\def ->
                        def.name == Just (String.Extra.leftOf "." doc.filename)
                    )
                |> Result.fromMaybe GraphQL.CliError.NoOperationMatchingFilename



-- SELECTIONS


{-| Finds the top-level query or mutation's selections
-}
toRootSelections : Document -> Result CliError (List Selection)
toRootSelections ((Document doc) as document) =
    toRootOperation document
        |> Result.map .selections


findFragmentDefinitionWithName : String -> Document -> Maybe FragmentDefinition
findFragmentDefinitionWithName name (Document doc) =
    doc.definitions
        |> List.filterMap toFragmentDefinition
        |> List.Extra.find (\fragment -> fragment.name == name)


toVariables : Document -> List VariableDefinition
toVariables document =
    toRootOperation document
        |> Result.map .variables
        |> Result.withDefault []


hasVariables : Document -> Bool
hasVariables document =
    List.length (toVariables document) > 0



-- INTERNALS


type alias Internals =
    { filename : String
    , contents : String
    , definitions : List Definition
    }


internalsDecoder : Json.Decode.Decoder Internals
internalsDecoder =
    Json.Decode.map3 Internals
        (Json.Decode.field "filename" Json.Decode.string)
        (Json.Decode.field "contents" Json.Decode.string)
        (Json.Decode.at [ "ast", "definitions" ] (Json.Decode.list definitionDecoder))


type Definition
    = Definition_Operation OperationDefinition
    | Definition_Fragment FragmentDefinition


toOperationDefinition : Definition -> Maybe OperationDefinition
toOperationDefinition def =
    case def of
        Definition_Operation innerDef ->
            Just innerDef

        _ ->
            Nothing


toFragmentDefinition : Definition -> Maybe FragmentDefinition
toFragmentDefinition def =
    case def of
        Definition_Fragment innerDef ->
            Just innerDef

        _ ->
            Nothing


definitionDecoder : Json.Decode.Decoder Definition
definitionDecoder =
    let
        fromKindToDefinitionDecoder : String -> Json.Decode.Decoder Definition
        fromKindToDefinitionDecoder kind =
            case kind of
                "OperationDefinition" ->
                    operationDefinitionDecoder
                        |> Json.Decode.map Definition_Operation

                "FragmentDefinition" ->
                    fragmentDefinitionDecoder
                        |> Json.Decode.map Definition_Fragment

                _ ->
                    Json.Decode.fail ("Unexpected definition kind: " ++ kind)
    in
    Json.Decode.field "kind" Json.Decode.string
        |> Json.Decode.andThen fromKindToDefinitionDecoder


type alias OperationDefinition =
    { name : Maybe String
    , operation : OperationType
    , variables : List VariableDefinition
    , selections : List Selection
    }


operationDefinitionDecoder : Json.Decode.Decoder OperationDefinition
operationDefinitionDecoder =
    Json.Decode.map4 OperationDefinition
        (Json.Decode.maybe (Json.Decode.at [ "name", "value" ] Json.Decode.string))
        (Json.Decode.field "operation" operationTypeDecoder)
        (Json.Decode.field "variableDefinitions"
            (Json.Decode.list GraphQL.Introspection.Document.VariableDefinition.decoder)
        )
        (Json.Decode.at [ "selectionSet", "selections" ]
            (Json.Decode.list selectionDecoder)
        )


type Selection
    = Selection_Field FieldSelection
    | Selection_FragmentSpread FragmentSpreadSelection
    | Selection_InlineFragment InlineFragmentSelection


toFieldSelections : Document -> Selection -> List FieldSelection
toFieldSelections ((Document doc) as document) selection =
    case selection of
        Selection_Field fieldSelection ->
            [ fieldSelection ]

        Selection_FragmentSpread frag ->
            case findFragmentDefinitionWithName frag.name document of
                Nothing ->
                    []

                Just fragment ->
                    fragment.selections
                        |> List.concatMap (toFieldSelections document)

        _ ->
            []


selectionDecoder : Json.Decode.Decoder Selection
selectionDecoder =
    let
        fromKindToSelectionDecoder : String -> Json.Decode.Decoder Selection
        fromKindToSelectionDecoder kind =
            case kind of
                "Field" ->
                    fieldSelectionDecoder
                        |> Json.Decode.map Selection_Field

                "FragmentSpread" ->
                    fragmentSpreadSelectionDecoder
                        |> Json.Decode.map Selection_FragmentSpread

                "InlineFragment" ->
                    inlineFragmentSelectionDecoder
                        |> Json.Decode.map Selection_InlineFragment

                _ ->
                    Json.Decode.fail ("Unexpected selection kind: " ++ kind)
    in
    Json.Decode.field "kind" Json.Decode.string
        |> Json.Decode.andThen fromKindToSelectionDecoder


type alias FieldSelection =
    { name : String
    , alias : Maybe String
    , selections : List Selection
    }


getNestedFields :
    String
    -> Schema
    -> Document
    ->
        List
            { parentTypeName : String
            , fieldSelection : FieldSelection
            }
getNestedFields operationTypeName schema ((Document doc) as document) =
    let
        topLevelOperationSelections : List Selection
        topLevelOperationSelections =
            doc.definitions
                |> List.head
                |> Maybe.andThen toOperationDefinition
                |> Maybe.map .selections
                |> Maybe.withDefault []

        toFieldSelectionInfo :
            String
            -> List Selection
            ->
                List
                    { parentTypeName : String
                    , fieldSelection : FieldSelection
                    }
        toFieldSelectionInfo parentTypeName selections =
            selections
                |> List.concatMap (toFieldSelections document)
                |> List.filter
                    (\fieldSelection ->
                        List.length fieldSelection.selections > 0
                    )
                |> List.concatMap
                    (\self ->
                        let
                            selfTypeName : String
                            selfTypeName =
                                Schema.findFieldForType
                                    { typeName = parentTypeName
                                    , fieldName = self.name
                                    }
                                    schema
                                    |> Maybe.map .type_
                                    |> Maybe.map TypeRef.toName
                                    |> Maybe.withDefault "UNEXPECTED_ERROR_IN_toFieldSelections_please_report_this"
                        in
                        { parentTypeName = parentTypeName
                        , fieldSelection = self
                        }
                            :: toFieldSelectionInfo selfTypeName self.selections
                    )
    in
    toFieldSelectionInfo
        operationTypeName
        topLevelOperationSelections


fieldSelectionDecoder : Json.Decode.Decoder FieldSelection
fieldSelectionDecoder =
    Json.Decode.map3 FieldSelection
        (Json.Decode.at [ "name", "value" ] Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.at [ "alias", "value" ] Json.Decode.string))
        (Json.Decode.maybe
            (Json.Decode.at [ "selectionSet", "selections" ] (Json.Decode.list (Json.Decode.lazy (\_ -> selectionDecoder))))
            |> Json.Decode.map (Maybe.withDefault [])
        )


type alias FragmentSpreadSelection =
    { name : String
    }


fragmentSpreadSelectionDecoder : Json.Decode.Decoder FragmentSpreadSelection
fragmentSpreadSelectionDecoder =
    Json.Decode.map FragmentSpreadSelection
        (Json.Decode.at [ "name", "value" ] Json.Decode.string)


type alias InlineFragmentSelection =
    { name : String
    , selections : List Selection
    }


inlineFragmentSelectionDecoder : Json.Decode.Decoder InlineFragmentSelection
inlineFragmentSelectionDecoder =
    Json.Decode.map2 InlineFragmentSelection
        (Json.Decode.at [ "typeCondition", "name", "value" ] Json.Decode.string)
        (Json.Decode.at [ "selectionSet", "selections" ] (Json.Decode.list (Json.Decode.lazy (\_ -> selectionDecoder))))


type alias VariableDefinition =
    GraphQL.Introspection.Document.VariableDefinition.VariableDefinition


type OperationType
    = Query
    | Mutation
    | Subscription


operationTypeDecoder : Json.Decode.Decoder OperationType
operationTypeDecoder =
    let
        fromStringToOperationTypeDecoder : String -> Json.Decode.Decoder OperationType
        fromStringToOperationTypeDecoder type_ =
            case type_ of
                "query" ->
                    Json.Decode.succeed Query

                "mutation" ->
                    Json.Decode.succeed Mutation

                "subscription" ->
                    Json.Decode.succeed Subscription

                _ ->
                    Json.Decode.fail ("Unexpected operation type: " ++ type_)
    in
    Json.Decode.string
        |> Json.Decode.andThen fromStringToOperationTypeDecoder


type alias FragmentDefinition =
    { name : String
    , typeName : String
    , selections : List Selection
    }


fragmentDefinitionDecoder : Json.Decode.Decoder FragmentDefinition
fragmentDefinitionDecoder =
    Json.Decode.map3 FragmentDefinition
        (Json.Decode.at [ "name", "value" ]
            Json.Decode.string
        )
        (Json.Decode.at [ "typeCondition", "name", "value" ]
            Json.Decode.string
        )
        (Json.Decode.at [ "selectionSet", "selections" ]
            (Json.Decode.list selectionDecoder)
        )
