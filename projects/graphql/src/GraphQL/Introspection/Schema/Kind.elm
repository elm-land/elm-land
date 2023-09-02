module GraphQL.Introspection.Schema.Kind exposing
    ( Kind(..)
    , decoder
    )

import Json.Decode


type Kind
    = Scalar
    | Object
    | Interface
    | Union
    | Enum
    | InputObject


decoder : Json.Decode.Decoder Kind
decoder =
    let
        fromStringToKind : String -> Json.Decode.Decoder Kind
        fromStringToKind str =
            case str of
                "SCALAR" ->
                    Json.Decode.succeed Scalar

                "OBJECT" ->
                    Json.Decode.succeed Object

                "INTERFACE" ->
                    Json.Decode.succeed Interface

                "UNION" ->
                    Json.Decode.succeed Union

                "ENUM" ->
                    Json.Decode.succeed Enum

                "INPUT_OBJECT" ->
                    Json.Decode.succeed InputObject

                _ ->
                    Json.Decode.fail ("Unknown kind: " ++ str)
    in
    Json.Decode.string
        |> Json.Decode.andThen fromStringToKind
