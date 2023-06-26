module GraphQL.Introspection.Document exposing
    ( Document, decoder
    , toName, toContents
    , Selection(..), toRootSelections
    , FieldSelection, getNestedFields, toFieldSelection
    )

{-| These decoders were translated from the official `graphql`
NPM package's `node_modules/graphql/language/ast.d.ts` file.

(It uses the `DocumentNode` type)


## Document

@docs Document, decoder

@docs toName, toContents


## Selection

@docs Selection, toRootSelections

-}

import GraphQL.Introspection.Schema as Schema exposing (Schema)
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


toRootOperation : Document -> Maybe OperationDefinition
toRootOperation (Document doc) =
    doc.definitions
        |> List.filterMap toOperationDefinition
        -- TODO: Report an Elm Land problem if there is no operation
        -- with a matching name.
        |> List.Extra.find
            (\def ->
                def.name == Just (String.Extra.leftOf "." doc.filename)
            )



-- SELECTIONS


{-| Finds the top-level query or mutation's selections
-}
toRootSelections : Document -> List Selection
toRootSelections ((Document doc) as document) =
    toRootOperation document
        |> Maybe.map .selections
        |> Maybe.withDefault []



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
        Definition_Operation opDef ->
            Just opDef

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
        (Json.Decode.maybe (Json.Decode.list variableDefinitionDecoder)
            |> Json.Decode.map (Maybe.withDefault [])
        )
        (Json.Decode.at [ "selectionSet", "selections" ]
            (Json.Decode.list selectionDecoder)
        )


type Selection
    = Selection_Field FieldSelection
    | Selection_FragmentSpread FragmentSpreadSelection
    | Selection_InlineFragment InlineFragmentSelection


toFieldSelection : Selection -> Maybe FieldSelection
toFieldSelection selection =
    case selection of
        Selection_Field fieldSelection ->
            Just fieldSelection

        _ ->
            Nothing


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
    Schema
    -> Document
    ->
        List
            { parentTypeName : String
            , fieldSelection : FieldSelection
            }
getNestedFields schema (Document doc) =
    let
        topLevelQuerySelections : List Selection
        topLevelQuerySelections =
            doc.definitions
                |> List.head
                |> Maybe.andThen toOperationDefinition
                |> Maybe.map .selections
                |> Maybe.withDefault []

        toFieldSelections :
            String
            -> List Selection
            ->
                List
                    { parentTypeName : String
                    , fieldSelection : FieldSelection
                    }
        toFieldSelections parentTypeName selections =
            selections
                |> List.filterMap toFieldSelection
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
                                    |> Maybe.map Schema.toTypeRefName
                                    |> Maybe.withDefault "UNEXPECTED_ERROR_IN_toFieldSelections_please_report_this"
                        in
                        { parentTypeName = parentTypeName
                        , fieldSelection = self
                        }
                            :: toFieldSelections selfTypeName self.selections
                    )
    in
    toFieldSelections
        (Schema.toQueryTypeName schema)
        topLevelQuerySelections


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
    { name : String
    , type_ : Type
    }


variableDefinitionDecoder : Json.Decode.Decoder VariableDefinition
variableDefinitionDecoder =
    Json.Decode.map2 VariableDefinition
        (Json.Decode.at [ "variable", "name" ] Json.Decode.string)
        (Json.Decode.at [ "type" ] typeDecoder)


type Type
    = Named NamedType
    | List_ Type
    | NonNull Type


typeDecoder : Json.Decode.Decoder Type
typeDecoder =
    let
        fromKindToTypeDecoder : String -> Json.Decode.Decoder Type
        fromKindToTypeDecoder str =
            case str of
                "LIST" ->
                    Json.Decode.field "ofType" typeDecoder
                        |> Json.Decode.map List_

                "NON_NULL" ->
                    Json.Decode.field "ofType" typeDecoder
                        |> Json.Decode.map NonNull

                _ ->
                    namedTypeDecoder
                        |> Json.Decode.map Named
    in
    Json.Decode.field "kind" Json.Decode.string
        |> Json.Decode.andThen fromKindToTypeDecoder


type alias NamedType =
    { name : String
    }


namedTypeDecoder : Json.Decode.Decoder NamedType
namedTypeDecoder =
    Json.Decode.map NamedType
        (Json.Decode.field "name" Json.Decode.string)


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
    {}


fragmentDefinitionDecoder : Json.Decode.Decoder FragmentDefinition
fragmentDefinitionDecoder =
    Json.Decode.succeed FragmentDefinition
