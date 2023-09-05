module GraphQL.Introspection.Document.Type exposing
    ( NamedType
    , Type(..)
    , inputTypeDecoder
    , toEncoderStringUnwrappingFirstMaybe
    , toImports
    , toName
    , toStringUnwrappingFirstMaybe
    )

import CodeGen.Import
import GraphQL.Introspection.Schema as Schema exposing (Schema)
import Json.Decode
import String.Extra


type Type
    = Named NamedType
    | List_ Type
    | NonNull Type


toName : Type -> String
toName type_ =
    case type_ of
        Named { name } ->
            name

        List_ inner ->
            toName inner

        NonNull inner ->
            toName inner


inputTypeDecoder : Json.Decode.Decoder Type
inputTypeDecoder =
    let
        namedInputTypeDecoder : Json.Decode.Decoder NamedType
        namedInputTypeDecoder =
            Json.Decode.map NamedType
                (Json.Decode.at [ "name", "value" ] Json.Decode.string)

        fromKindToTypeDecoder : String -> Json.Decode.Decoder Type
        fromKindToTypeDecoder str =
            case str of
                "ListType" ->
                    Json.Decode.field "type" inputTypeDecoder
                        |> Json.Decode.map List_

                "NonNullType" ->
                    Json.Decode.field "type" inputTypeDecoder
                        |> Json.Decode.map NonNull

                _ ->
                    namedInputTypeDecoder
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


toStringUnwrappingFirstMaybe : Schema -> Type -> String
toStringUnwrappingFirstMaybe schema type_ =
    toElmTypeRefString schema
        (unwrapFirstMaybe (toElmTypeRef type_))


toEncoderStringUnwrappingFirstMaybe : Schema -> Type -> String
toEncoderStringUnwrappingFirstMaybe schema type_ =
    toElmTypeEncoderString schema
        (unwrapFirstMaybe (toElmTypeRef type_))


toImports :
    { namespace : String
    , schema : Schema
    , name : String
    }
    -> List CodeGen.Import.Import
toImports { namespace, schema, name } =
    if name == "ID" then
        [ CodeGen.Import.new [ "GraphQL", "Scalar", "Id" ] ]

    else if Schema.isBuiltInScalarType name then
        []

    else if Schema.isScalarType name schema then
        [ CodeGen.Import.new [ namespace, "Scalars", name ] ]

    else if Schema.isEnumType name schema then
        [ CodeGen.Import.new [ namespace, "Enums", name ] ]

    else
        [ CodeGen.Import.new [ "Api", "Input" ]
        , CodeGen.Import.new [ "Api", "Internals", "Input" ]
        ]



-- ELM TYPE REF STUFF


type ElmTypeRef
    = ElmTypeRef_Named { name : String }
    | ElmTypeRef_List ElmTypeRef
    | ElmTypeRef_Maybe ElmTypeRef


unwrapFirstMaybe : ElmTypeRef -> ElmTypeRef
unwrapFirstMaybe typeRef =
    case typeRef of
        ElmTypeRef_Maybe inner ->
            inner

        _ ->
            typeRef


toElmTypeRefString : Schema -> ElmTypeRef -> String
toElmTypeRefString schema outerElmTypeRef =
    let
        toStringHelper : ElmTypeRef -> String
        toStringHelper elmTypeRef =
            case elmTypeRef of
                ElmTypeRef_Named { name } ->
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
                            if Schema.isScalarType name schema then
                                "GraphQL.Scalars." ++ String.Extra.decapitalize name

                            else
                                "Api.Input." ++ name

                ElmTypeRef_List (ElmTypeRef_Named value) ->
                    "List " ++ toStringHelper (ElmTypeRef_Named value)

                ElmTypeRef_List innerElmTypeRef ->
                    "List (" ++ toStringHelper innerElmTypeRef ++ ")"

                ElmTypeRef_Maybe (ElmTypeRef_Named value) ->
                    "Maybe " ++ toStringHelper (ElmTypeRef_Named value)

                ElmTypeRef_Maybe innerElmTypeRef ->
                    "Maybe (" ++ toStringHelper innerElmTypeRef ++ ")"
    in
    toStringHelper outerElmTypeRef


toElmTypeEncoderString : Schema -> ElmTypeRef -> String
toElmTypeEncoderString schema outerElmTypeRef =
    let
        toStringHelper : ElmTypeRef -> String
        toStringHelper elmTypeRef =
            case elmTypeRef of
                ElmTypeRef_Named { name } ->
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
                            if Schema.isScalarType name schema then
                                "GraphQL.Scalars.${name}.encode"
                                    |> String.replace "${name}" name

                            else
                                "(Dict.toList >> GraphQL.Encode.input)"

                ElmTypeRef_List (ElmTypeRef_Named value) ->
                    "GraphQL.Encode.list " ++ toStringHelper (ElmTypeRef_Named value)

                ElmTypeRef_List innerElmTypeRef ->
                    "GraphQL.Encode.list (" ++ toStringHelper innerElmTypeRef ++ ")"

                ElmTypeRef_Maybe (ElmTypeRef_Named value) ->
                    "GraphQL.Encode.maybe " ++ toStringHelper (ElmTypeRef_Named value)

                ElmTypeRef_Maybe innerElmTypeRef ->
                    "GraphQL.Encode.maybe (" ++ toStringHelper innerElmTypeRef ++ ")"
    in
    toStringHelper outerElmTypeRef


toElmTypeRef : Type -> ElmTypeRef
toElmTypeRef typeRef =
    toElmTypeRefHelp { isMaybe = True } typeRef


toElmTypeRefHelp :
    { isMaybe : Bool }
    -> Type
    -> ElmTypeRef
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


toNamedType : Type -> NamedType
toNamedType type_ =
    case type_ of
        Named x ->
            x

        List_ inner ->
            toNamedType inner

        NonNull inner ->
            toNamedType inner
