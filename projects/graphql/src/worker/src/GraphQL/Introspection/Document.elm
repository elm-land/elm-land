module GraphQL.Introspection.Document exposing
    ( Document, decoder
    , toName, toContents
    )

{-| These decoders were translated from the official `graphql`
NPM package's `node_modules/graphql/language/ast.d.ts` file.

(It uses `DocumentNode` type)

@docs Document, decoder

@docs toName, toContents

-}

import Json.Decode


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
    , selection : List Selection
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


fieldSelectionDecoder : Json.Decode.Decoder FieldSelection
fieldSelectionDecoder =
    Json.Decode.map3 FieldSelection
        (Json.Decode.at [ "name", "value" ] Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.at [ "name", "value" ] Json.Decode.string))
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
