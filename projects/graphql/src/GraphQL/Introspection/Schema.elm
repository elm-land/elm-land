module GraphQL.Introspection.Schema exposing
    ( Schema, decoder
    , toQueryTypeName, toMutationTypeName, findSubscriptionType
    , toTypeRefNameUnwrappingFirstMaybe, toTypeRefEncoderStringUnwrappingFirstMaybe
    , Type(..)
    , findQueryType, findMutationType
    , findTypeWithName
    , toTypeName
    , ObjectType, toObjectType
    , EnumType, findEnumTypeWithName, isEnumType
    , UnionType, toUnionType, isUnionType
    , InputObjectType, findInputObjectTypeWithName
    , InputValue
    , ScalarType
    , InterfaceType
    , Field, findFieldForType, findFieldWithName
    , isBuiltInScalarType, isScalarType
    , findInputTypes, isInputType
    )

{-| These decoders were translated from the official `graphql`
NPM package's `./graphql/utilties/getIntrospectionQuery.d.ts` file.


## Schema

@docs Schema, decoder
@docs toQueryTypeName, toMutationTypeName, findSubscriptionType

@docs toTypeRefNameUnwrappingFirstMaybe, toTypeRefEncoderStringUnwrappingFirstMaybe


## Type

@docs Type
@docs findQueryType, findMutationType
@docs findTypeWithName
@docs toTypeName

@docs ObjectType, toObjectType
@docs EnumType, findEnumTypeWithName, isEnumType
@docs UnionType, toUnionType, isUnionType
@docs InputObjectType, findInputObjectTypeWithName
@docs InputValue
@docs ScalarType
@docs InterfaceType


## Field

@docs Field, findFieldForType, findFieldWithName

@docs TypeRef, toTypeRefName, toTypeRefAnnotation

@docs isBuiltInScalarType, isScalarType
@docs toScalarTypeNames

@docs ElmTypeRef, toElmTypeRef

-}

import GraphQL.Introspection.Schema.Kind as Kind exposing (Kind)
import GraphQL.Introspection.Schema.NamedTypeRef as NamedTypeRef exposing (NamedTypeRef)
import GraphQL.Introspection.Schema.TypeRef as TypeRef exposing (TypeRef)
import Json.Decode
import List.Extra
import Set exposing (Set)
import String.Extra


type Schema
    = Schema Internals


decoder : Json.Decode.Decoder Schema
decoder =
    Json.Decode.map Schema internalsDecoder


toQueryTypeName : Schema -> String
toQueryTypeName (Schema schema) =
    schema.queryTypeName


toMutationTypeName : Schema -> String
toMutationTypeName (Schema schema) =
    schema.mutationTypeName



-- TYPES


findQueryType : Schema -> Maybe ObjectType
findQueryType ((Schema schema) as wrappedSchema) =
    findTypeWithName schema.queryTypeName wrappedSchema
        |> Maybe.andThen toObjectType


findInputObjectTypeWithName : String -> Schema -> Maybe InputObjectType
findInputObjectTypeWithName name schema =
    findTypeWithName name schema
        |> Maybe.andThen toInputObjectType


findEnumTypeWithName : String -> Schema -> Maybe EnumType
findEnumTypeWithName name schema =
    findTypeWithName name schema
        |> Maybe.andThen toEnumType


findInputTypes : Set String -> Schema -> List InputObjectType
findInputTypes names schema =
    Set.toList names
        |> List.filterMap
            (\name ->
                findInputObjectTypeWithName name schema
            )


findMutationType : Schema -> Maybe ObjectType
findMutationType ((Schema schema) as wrappedSchema) =
    findTypeWithName schema.mutationTypeName wrappedSchema
        |> Maybe.andThen toObjectType


findSubscriptionType : Schema -> Maybe ObjectType
findSubscriptionType ((Schema schema) as wrappedSchema) =
    findTypeWithName schema.subscriptionTypeName wrappedSchema
        |> Maybe.andThen toObjectType


findTypeWithName : String -> Schema -> Maybe Type
findTypeWithName name (Schema schema) =
    let
        hasMatchingName : Type -> Bool
        hasMatchingName type_ =
            toTypeName type_ == name
    in
    List.Extra.find hasMatchingName schema.types


toTypeRefNameUnwrappingFirstMaybe : String -> TypeRef -> Schema -> String
toTypeRefNameUnwrappingFirstMaybe namespace typeRef schema =
    let
        outerElmTypeRef : TypeRef.ElmTypeRef
        outerElmTypeRef =
            TypeRef.toElmTypeRef typeRef

        toStringHelper : TypeRef.ElmTypeRef -> String
        toStringHelper elmTypeRef =
            case elmTypeRef of
                TypeRef.ElmTypeRef_Named { name } ->
                    case name of
                        "String" ->
                            "String"

                        "Int" ->
                            "Int"

                        "Float" ->
                            "Float"

                        "Boolean" ->
                            "Bool"

                        "ID" ->
                            "GraphQL.Scalar.Id.Id"

                        _ ->
                            if isScalarType name schema then
                                "GraphQL.Scalars." ++ String.Extra.decapitalize name

                            else if isEnumType name schema then
                                namespace ++ ".Enum." ++ name ++ "." ++ name

                            else
                                namespace ++ ".Input." ++ name

                TypeRef.ElmTypeRef_List (TypeRef.ElmTypeRef_Named value) ->
                    "List " ++ toStringHelper (TypeRef.ElmTypeRef_Named value)

                TypeRef.ElmTypeRef_List innerElmTypeRef ->
                    "List (" ++ toStringHelper innerElmTypeRef ++ ")"

                TypeRef.ElmTypeRef_Maybe (TypeRef.ElmTypeRef_Named value) ->
                    "Maybe " ++ toStringHelper (TypeRef.ElmTypeRef_Named value)

                TypeRef.ElmTypeRef_Maybe innerElmTypeRef ->
                    "Maybe (" ++ toStringHelper innerElmTypeRef ++ ")"
    in
    toStringHelper outerElmTypeRef


toTypeRefEncoderStringUnwrappingFirstMaybe : String -> TypeRef -> Schema -> String
toTypeRefEncoderStringUnwrappingFirstMaybe namespace typeRef schema =
    let
        outerElmTypeRef : TypeRef.ElmTypeRef
        outerElmTypeRef =
            TypeRef.toElmTypeRef typeRef

        toStringHelper : TypeRef.ElmTypeRef -> String
        toStringHelper elmTypeRef =
            case elmTypeRef of
                TypeRef.ElmTypeRef_Named { name } ->
                    case name of
                        "String" ->
                            "GraphQL.Encode.string"

                        "Int" ->
                            "GraphQL.Encode.int"

                        "Float" ->
                            "GraphQL.Encode.float"

                        "Boolean" ->
                            "GraphQL.Encode.bool"

                        "ID" ->
                            "GraphQL.Encode.id"

                        _ ->
                            if isScalarType name schema then
                                "GraphQL.Scalars.${name}.encode"
                                    |> String.replace "${name}" name

                            else if isEnumType name schema then
                                "${namespace}.Enum.${name}.encode"
                                    |> String.replace "${namespace}" namespace
                                    |> String.replace "${name}" name

                            else
                                "(Dict.toList >> GraphQL.Encode.input)"

                TypeRef.ElmTypeRef_List (TypeRef.ElmTypeRef_Named value) ->
                    "GraphQL.Encode.list " ++ toStringHelper (TypeRef.ElmTypeRef_Named value)

                TypeRef.ElmTypeRef_List innerElmTypeRef ->
                    "GraphQL.Encode.list (" ++ toStringHelper innerElmTypeRef ++ ")"

                TypeRef.ElmTypeRef_Maybe (TypeRef.ElmTypeRef_Named value) ->
                    "GraphQL.Encode.maybe " ++ toStringHelper (TypeRef.ElmTypeRef_Named value)

                TypeRef.ElmTypeRef_Maybe innerElmTypeRef ->
                    "GraphQL.Encode.maybe (" ++ toStringHelper innerElmTypeRef ++ ")"
    in
    toStringHelper outerElmTypeRef


findFieldForType :
    { typeName : String
    , fieldName : String
    }
    -> Schema
    -> Maybe Field
findFieldForType { typeName, fieldName } schema =
    let
        parentObjectType : Maybe ObjectType
        parentObjectType =
            findTypeWithName typeName schema
                |> Maybe.andThen toObjectType
    in
    parentObjectType
        |> Maybe.andThen (findFieldWithName fieldName)


toTypeName : Type -> String
toTypeName type_ =
    case type_ of
        Type_Scalar data ->
            data.name

        Type_Object data ->
            data.name

        Type_Interface data ->
            data.name

        Type_Union data ->
            data.name

        Type_Enum data ->
            data.name

        Type_InputObject data ->
            data.name


toObjectType : Type -> Maybe ObjectType
toObjectType type_ =
    case type_ of
        Type_Object data ->
            Just data

        _ ->
            Nothing


toUnionType : Type -> Maybe UnionType
toUnionType type_ =
    case type_ of
        Type_Union data ->
            Just data

        _ ->
            Nothing


toInputObjectType : Type -> Maybe InputObjectType
toInputObjectType type_ =
    case type_ of
        Type_InputObject data ->
            Just data

        _ ->
            Nothing


toEnumType : Type -> Maybe EnumType
toEnumType type_ =
    case type_ of
        Type_Enum data ->
            Just data

        _ ->
            Nothing



-- FIELDS


{-| Find details for a field on an `ObjectType` or `Interface`
-}
findFieldWithName :
    String
    -> { objectTypeOrInterface | fields : List Field }
    -> Maybe Field
findFieldWithName name { fields } =
    let
        hasMatchingName : Field -> Bool
        hasMatchingName field =
            field.name == name
    in
    List.Extra.find hasMatchingName fields



-- INTERNALS


type alias Internals =
    { queryTypeName : String
    , mutationTypeName : String
    , subscriptionTypeName : String
    , types : List Type
    }


internalsDecoder : Json.Decode.Decoder Internals
internalsDecoder =
    Json.Decode.map4 Internals
        (Json.Decode.at [ "queryType", "name" ] Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.at [ "mutationType", "name" ] Json.Decode.string)
            |> Json.Decode.map (Maybe.withDefault "Mutation")
        )
        (Json.Decode.maybe (Json.Decode.at [ "subscriptionType", "name" ] Json.Decode.string)
            |> Json.Decode.map (Maybe.withDefault "Subscription")
        )
        (Json.Decode.field "types" (Json.Decode.list typeDecoder))



-- TYPE


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
                Kind.Scalar ->
                    scalarTypeDecoder
                        |> Json.Decode.map Type_Scalar

                Kind.Object ->
                    objectTypeDecoder
                        |> Json.Decode.map Type_Object

                Kind.Interface ->
                    interfaceTypeDecoder
                        |> Json.Decode.map Type_Interface

                Kind.Union ->
                    unionTypeDecoder
                        |> Json.Decode.map Type_Union

                Kind.Enum ->
                    enumTypeDecoder
                        |> Json.Decode.map Type_Enum

                Kind.InputObject ->
                    inputObjectTypeDecoder
                        |> Json.Decode.map Type_InputObject
    in
    Json.Decode.field "kind" Kind.decoder
        |> Json.Decode.andThen fromKindToTypeDecoder



-- SCALAR TYPE


type alias ScalarType =
    { name : String
    , description : Maybe String
    }


scalarTypeDecoder : Json.Decode.Decoder ScalarType
scalarTypeDecoder =
    Json.Decode.map2 ScalarType
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))



-- OBJECT TYPE


type alias ObjectType =
    { name : String
    , description : Maybe String
    , fields : List Field
    , interfaces : List NamedTypeRef
    }


objectTypeDecoder : Json.Decode.Decoder ObjectType
objectTypeDecoder =
    Json.Decode.map4 ObjectType
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "fields" (Json.Decode.list fieldDecoder))
        (Json.Decode.field "interfaces" (Json.Decode.list NamedTypeRef.decoder))



-- INTERFACE TYPE


type alias InterfaceType =
    { name : String
    , description : Maybe String
    , fields : List Field
    , interfaces : List NamedTypeRef
    }


interfaceTypeDecoder : Json.Decode.Decoder InterfaceType
interfaceTypeDecoder =
    Json.Decode.map4 InterfaceType
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "fields" (Json.Decode.list fieldDecoder))
        (Json.Decode.field "interfaces" (Json.Decode.list NamedTypeRef.decoder))



-- UNION TYPE


type alias UnionType =
    { name : String
    , description : Maybe String
    , possibleTypes : List NamedTypeRef
    }


unionTypeDecoder : Json.Decode.Decoder UnionType
unionTypeDecoder =
    Json.Decode.map3 UnionType
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "possibleTypes" (Json.Decode.list NamedTypeRef.decoder))



-- ENUM TYPE


type alias EnumType =
    { name : String
    , description : Maybe String
    , enumValues : List EnumValue
    }


enumTypeDecoder : Json.Decode.Decoder EnumType
enumTypeDecoder =
    Json.Decode.map3 EnumType
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "enumValues" (Json.Decode.list enumValueDecoder))



-- INPUT OBJECT TYPE


type alias InputObjectType =
    { name : String
    , description : Maybe String
    , inputFields : List InputValue
    }


inputObjectTypeDecoder : Json.Decode.Decoder InputObjectType
inputObjectTypeDecoder =
    Json.Decode.map3 InputObjectType
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "inputFields" (Json.Decode.list inputValueDecoder))



-- ENUM VALUE


type alias EnumValue =
    { name : String
    , description : Maybe String
    , deprecationReason : Maybe String
    }


enumValueDecoder : Json.Decode.Decoder EnumValue
enumValueDecoder =
    Json.Decode.map3 EnumValue
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "deprecationReason" Json.Decode.string))



-- FIELD


type alias Field =
    { name : String
    , description : Maybe String
    , args : List InputValue
    , type_ : TypeRef
    , deprecationReason : Maybe String
    }


fieldDecoder : Json.Decode.Decoder Field
fieldDecoder =
    Json.Decode.map5 Field
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "args" (Json.Decode.list inputValueDecoder))
        (Json.Decode.field "type" TypeRef.decoder)
        (Json.Decode.maybe (Json.Decode.field "deprecationReason" Json.Decode.string))



-- INPUT VALUE


type alias InputValue =
    { name : String
    , description : Maybe String
    , type_ : TypeRef
    , defaultValue : Maybe String
    , deprecationReason : Maybe String
    }


inputValueDecoder : Json.Decode.Decoder InputValue
inputValueDecoder =
    Json.Decode.map5 InputValue
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.field "description" Json.Decode.string))
        (Json.Decode.field "type" TypeRef.decoder)
        (Json.Decode.field "defaultValue" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "deprecationReason" Json.Decode.string))



-- CHECKIN STUFF


toScalarTypeNames : Schema -> List String
toScalarTypeNames (Schema schema) =
    schema.types
        |> List.filterMap
            (\type_ ->
                case type_ of
                    Type_Scalar scalarType ->
                        Just scalarType.name

                    _ ->
                        Nothing
            )


isInputType : String -> Schema -> Bool
isInputType name (Schema schema) =
    schema.types
        |> List.any
            (\type_ ->
                case type_ of
                    Type_InputObject inputType ->
                        inputType.name == name

                    _ ->
                        False
            )


isScalarType : String -> Schema -> Bool
isScalarType typeName schema =
    Set.member
        typeName
        (Set.fromList (toScalarTypeNames schema))


isEnumType : String -> Schema -> Bool
isEnumType typeName schema =
    case findTypeWithName typeName schema of
        Just (Type_Enum _) ->
            True

        _ ->
            False


isUnionType : String -> Schema -> Bool
isUnionType typeName schema =
    case findTypeWithName typeName schema of
        Just (Type_Union _) ->
            True

        _ ->
            False


isBuiltInScalarType : String -> Bool
isBuiltInScalarType typeName =
    List.member
        typeName
        [ "ID", "String", "Float", "Int", "Boolean" ]
