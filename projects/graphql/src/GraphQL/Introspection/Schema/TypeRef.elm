module GraphQL.Introspection.Schema.TypeRef exposing
    ( TypeRef(..), decoder
    , toName, toAnnotation
    , isRequired
    , ElmTypeRef(..), toElmTypeRef
    )

{-|

@docs TypeRef, decoder
@docs toName, toAnnotation
@docs isRequired

@docs toStringUnwrappingFirstMaybe
@docs toEncoderStringUnwrappingFirstMaybe

@docs ElmTypeRef, toElmTypeRef

-}

import GraphQL.Introspection.Schema.Kind as Kind exposing (Kind)
import GraphQL.Introspection.Schema.NamedTypeRef as NamedTypeRef exposing (NamedTypeRef)
import Json.Decode



-- TYPE REF


type TypeRef
    = Named NamedTypeRef
    | List_ TypeRef
    | NonNull TypeRef


isRequired : TypeRef -> Bool
isRequired ref_ =
    case ref_ of
        NonNull _ ->
            True

        List_ _ ->
            False

        Named _ ->
            False


toName : TypeRef -> String
toName typeRef =
    case typeRef of
        Named data ->
            data.name

        List_ inner ->
            toName inner

        NonNull inner ->
            toName inner


toAnnotation : String -> TypeRef -> String
toAnnotation collisionFreeName typeRef =
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


decoder : Json.Decode.Decoder TypeRef
decoder =
    let
        fromKindToTypeRefDecoder : String -> Json.Decode.Decoder TypeRef
        fromKindToTypeRefDecoder str =
            case str of
                "LIST" ->
                    Json.Decode.field "ofType" decoder
                        |> Json.Decode.map List_

                "NON_NULL" ->
                    Json.Decode.field "ofType" decoder
                        |> Json.Decode.map NonNull

                _ ->
                    NamedTypeRef.decoder
                        |> Json.Decode.map Named
    in
    Json.Decode.field "kind" Json.Decode.string
        |> Json.Decode.andThen fromKindToTypeRefDecoder



-- ELM TYPE REF


{-| Because required is the default, this function helps flip non-null into a `Maybe`.

This data type makes it easier to generate Elm code.

See usage with `toAnnotation` below.

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
