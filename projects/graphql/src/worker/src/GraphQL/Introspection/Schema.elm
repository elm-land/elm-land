module GraphQL.Introspection.Schema exposing
    ( Schema, decoder
    , toQueryTypeName
    , Type(..)
    , findQueryType, findTypeWithName
    , toTypeName
    , ObjectType, toObjectType
    , ScalarType, EnumType, InputObjectType
    , InterfaceType, UnionType
    , Field, findFieldForType, findFieldWithName
    , TypeRef, toTypeRefName, toTypeRefAnnotation
    , isBuiltInScalarType, isScalarType
    , ElmTypeRef(..), toElmTypeRef
    )

{-| These decoders were translated from the official `graphql`
NPM package's `./graphql/utilties/getIntrospectionQuery.d.ts` file.


## Schema

@docs Schema, decoder
@docs toQueryTypeName


## Type

@docs Type
@docs findQueryType, findTypeWithName
@docs toTypeName

@docs ObjectType, toObjectType
@docs ScalarType, EnumType, InputObjectType
@docs InterfaceType, UnionType


## Field

@docs Field, findFieldForType, findFieldWithName

@docs TypeRef, toTypeRefName, toTypeRefAnnotation

@docs isBuiltInScalarType, isScalarType
@docs toScalarTypeNames

@docs ElmTypeRef, toElmTypeRef

-}

import Json.Decode
import List.Extra
import Set exposing (Set)


type Schema
    = Schema Internals


decoder : Json.Decode.Decoder Schema
decoder =
    Json.Decode.map Schema internalsDecoder


toQueryTypeName : Schema -> String
toQueryTypeName (Schema schema) =
    schema.queryTypeName



-- TYPES


findQueryType : Schema -> Maybe ObjectType
findQueryType ((Schema schema) as wrappedSchema) =
    findTypeWithName schema.queryTypeName wrappedSchema
        |> Maybe.andThen toObjectType


findTypeWithName : String -> Schema -> Maybe Type
findTypeWithName name (Schema schema) =
    let
        hasMatchingName : Type -> Bool
        hasMatchingName type_ =
            toTypeName type_ == name
    in
    List.Extra.find hasMatchingName schema.types


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
    , mutationTypeName : Maybe String
    , types : List Type
    }


internalsDecoder : Json.Decode.Decoder Internals
internalsDecoder =
    Json.Decode.map3 Internals
        (Json.Decode.at [ "queryType", "name" ] Json.Decode.string)
        (Json.Decode.maybe (Json.Decode.at [ "mutationType", "name" ] Json.Decode.string))
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



-- KIND


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
        (Json.Decode.field "interfaces" (Json.Decode.list namedTypeRefDecoder))



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
        (Json.Decode.field "interfaces" (Json.Decode.list namedTypeRefDecoder))



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
        (Json.Decode.field "possibleTypes" (Json.Decode.list namedTypeRefDecoder))



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
        (Json.Decode.field "type" typeRefDecoder)
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
        (Json.Decode.field "type" typeRefDecoder)
        (Json.Decode.field "defaultValue" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.maybe (Json.Decode.field "deprecationReason" Json.Decode.string))



-- TYPE REF


type TypeRef
    = Named NamedTypeRef
    | List_ TypeRef
    | NonNull TypeRef


toTypeRefName : TypeRef -> String
toTypeRefName typeRef =
    case typeRef of
        Named data ->
            data.name

        List_ inner ->
            toTypeRefName inner

        NonNull inner ->
            toTypeRefName inner


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


isScalarType : String -> Schema -> Bool
isScalarType typeName schema =
    Set.member
        typeName
        (Set.fromList (toScalarTypeNames schema))


isBuiltInScalarType : String -> Bool
isBuiltInScalarType typeName =
    List.member
        typeName
        [ "ID", "String", "Float", "Int", "Boolean" ]


toTypeRefAnnotation : String -> TypeRef -> String
toTypeRefAnnotation collisionFreeName typeRef =
    let
        toElmTypeRefAnnotation : ElmTypeRef -> String
        toElmTypeRefAnnotation elmTypeRef =
            case elmTypeRef of
                ElmTypeRef_Named { name } ->
                    collisionFreeName

                ElmTypeRef_List (ElmTypeRef_Named value) ->
                    "List " ++ toElmTypeRefAnnotation (ElmTypeRef_Named value)

                ElmTypeRef_List innerElmTypeRef ->
                    "List (" ++ toElmTypeRefAnnotation innerElmTypeRef ++ ")"

                ElmTypeRef_Maybe (ElmTypeRef_Named value) ->
                    "Maybe " ++ toElmTypeRefAnnotation (ElmTypeRef_Named value)

                ElmTypeRef_Maybe innerElmTypeRef ->
                    "Maybe (" ++ toElmTypeRefAnnotation innerElmTypeRef ++ ")"
    in
    toElmTypeRefAnnotation (toElmTypeRef typeRef)


typeRefDecoder : Json.Decode.Decoder TypeRef
typeRefDecoder =
    let
        fromKindToTypeRefDecoder : String -> Json.Decode.Decoder TypeRef
        fromKindToTypeRefDecoder str =
            case str of
                "LIST" ->
                    Json.Decode.field "ofType" typeRefDecoder
                        |> Json.Decode.map List_

                "NON_NULL" ->
                    Json.Decode.field "ofType" typeRefDecoder
                        |> Json.Decode.map NonNull

                _ ->
                    namedTypeRefDecoder
                        |> Json.Decode.map Named
    in
    Json.Decode.field "kind" Json.Decode.string
        |> Json.Decode.andThen fromKindToTypeRefDecoder



-- NAMED TYPE REF


type alias NamedTypeRef =
    { kind : Kind
    , name : String
    }


namedTypeRefDecoder : Json.Decode.Decoder NamedTypeRef
namedTypeRefDecoder =
    Json.Decode.map2 NamedTypeRef
        (Json.Decode.field "kind" kindDecoder)
        (Json.Decode.field "name" Json.Decode.string)



-- ELM TYPE REF


{-| Because required is the default, this function helps flip non-null into a `Maybe`.

This data type makes it easier to generate Elm code.

See usage with `toTypeRefAnnotation` below.

-}
type ElmTypeRef
    = ElmTypeRef_Named NamedTypeRef
    | ElmTypeRef_List ElmTypeRef
    | ElmTypeRef_Maybe ElmTypeRef


toElmTypeRef : TypeRef -> ElmTypeRef
toElmTypeRef typeRef =
    toElmTypeRefHelp { isMaybe = True } typeRef


toElmTypeRefHelp : { isMaybe : Bool } -> TypeRef -> ElmTypeRef
toElmTypeRefHelp options typeRef =
    let
        applyMaybe : ElmTypeRef -> ElmTypeRef
        applyMaybe inner =
            if options.isMaybe then
                ElmTypeRef_Maybe inner

            else
                inner
    in
    case typeRef of
        NonNull innerTypeRef ->
            toElmTypeRefHelp
                { options | isMaybe = False }
                innerTypeRef

        List_ innerTypeRef ->
            ElmTypeRef_List (toElmTypeRefHelp { options | isMaybe = True } innerTypeRef)
                |> applyMaybe

        Named value ->
            ElmTypeRef_Named value
                |> applyMaybe
