module GraphQL.Introspection.Schema exposing (Schema, decoder)

{-| These decoders were translated from the official `graphql`
NPM package's `./graphql/utilties/getIntrospectionQuery.d.ts` file.
-}

import Json.Decode


type Schema
    = Schema Internals


decoder : Json.Decode.Decoder Schema
decoder =
    Json.Decode.map Schema internalsDecoder



-- INTERNALS


type alias Internals =
    { queryType : String
    , mutationType : Maybe String
    , types : List Type
    }


internalsDecoder : Json.Decode.Decoder Internals
internalsDecoder =
    Json.Decode.map3 Internals
        (Json.Decode.field "queryType" namedTypeRefDecoder)
        (Json.Decode.maybe
            (Json.Decode.field "mutationType" namedTypeRefDecoder)
        )
        (Json.Decode.list typeDecoder)


type Type
    = Type_Scalar ScalarType
    | Type_Object ObjectType
    | Type_Interface InterfaceType
    | Type_Union UnionType
    | Type_Enum EnumType
    | Type_InputObject InputObjectType


typeDecoder : Json.Decode.Decoder Type
typeDecoder =
    let
        fromKindToTypeDecoder : Kind -> Json.Decode.Decoder Type
        fromKindToTypeDecoder kind =
            case kind of
                Kind_Scalar ->
                    scalarTypeDecoder
                        |> Json.Decode.map Type_Scalar

                Kind_Object ->
                    objectTypeDecoder
                        |> Json.Decode.map Type_Object

                Kind_Interface ->
                    interfaceTypeDecoder
                        |> Json.Decode.map Type_Interface

                Kind_Union ->
                    unionTypeDecoder
                        |> Json.Decode.map Type_Union

                Kind_Enum ->
                    enumTypeDecoder
                        |> Json.Decode.map Type_Enum

                Kind_InputObject ->
                    inputObjectTypeDecoder
                        |> Json.Decode.map Type_InputObject
    in
    Json.Decode.field "kind" kindDecoder
        |> Json.Decode.andThen fromKindToTypeDecoder


type Kind
    = Kind_Scalar
    | Kind_Object
    | Kind_Interface
    | Kind_Union
    | Kind_Enum
    | Kind_InputObject


kindDecoder : Json.Decode.Decoder Kind
kindDecoder =
    let
        fromStringToKind : String -> Json.Decode.Decoder Kind
        fromStringToKind str =
            case str of
                "SCALAR" ->
                    Json.Decode.succeed Kind_Scalar

                "OBJECT" ->
                    Json.Decode.succeed Kind_Object

                "INTERFACE" ->
                    Json.Decode.succeed Kind_Interface

                "UNION" ->
                    Json.Decode.succeed Kind_Union

                "ENUM" ->
                    Json.Decode.succeed Kind_Enum

                "INPUT_OBJECT" ->
                    Json.Decode.succeed Kind_InputObject

                _ ->
                    Json.Decode.fail ("Unknown kind: " ++ str)
    in
    Json.Decode.string
        |> Json.Decode.andThen fromStringToKind


type alias ScalarType =
    { name : String
    , description : Maybe String
    }


type alias ObjectType =
    { name : String
    , description : Maybe String
    , fields : List Field
    , interfaces : List NamedTypeRef
    }


type alias InterfaceType =
    { name : String
    , description : Maybe String
    , fields : List Field
    , interfaces : List NamedTypeRef
    }


type alias UnionType =
    { name : String
    , description : Maybe String
    , possibleTypes : List NamedTypeRef
    }


type alias EnumType =
    { name : String
    , description : Maybe String
    , enumValues : List EnumValue
    }


type alias InputObjectType =
    { name : String
    , description : Maybe String
    , inputFields : List InputValue
    }


type alias EnumValue =
    { name : String
    , description : Maybe String
    , deprecationReason : Maybe String
    }


type alias Field =
    { name : String
    , description : Maybe String
    , args : List InputValue
    , type_ : NamedTypeRef
    , deprecationReason : Maybe String
    }


type alias InputValue =
    { name : String
    , type_ : NamedTypeRef
    , description : Maybe String
    , defaultValue : Maybe String
    , deprecationReason : Maybe String
    }


type alias NamedTypeRef =
    { kind : Kind
    , name : String
    }


namedTypeRefDecoder : Json.Decode.Decoder NamedTypeRef
namedTypeRefDecoder =
    Json.Decode.map2 NamedTypeRef
        (Json.Decode.field "kind" kindDecoder)
