module GraphQL.Introspection.Schema.NamedTypeRef exposing
    ( NamedTypeRef
    , decoder
    )

import GraphQL.Introspection.Schema.Kind as Kind exposing (Kind)
import Json.Decode


type alias NamedTypeRef =
    { kind : Kind
    , name : String
    }


decoder : Json.Decode.Decoder NamedTypeRef
decoder =
    Json.Decode.map2 NamedTypeRef
        (Json.Decode.field "kind" Kind.decoder)
        (Json.Decode.field "name" Json.Decode.string)
