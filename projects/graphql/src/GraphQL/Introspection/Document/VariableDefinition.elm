module GraphQL.Introspection.Document.VariableDefinition exposing
    ( VariableDefinition
    , decoder
    , isRequired
    )

import GraphQL.Introspection.Document.Type as Type exposing (Type)
import Json.Decode


type alias VariableDefinition =
    { name : String
    , type_ : Type
    }


decoder : Json.Decode.Decoder VariableDefinition
decoder =
    Json.Decode.map2 VariableDefinition
        (Json.Decode.at [ "variable", "name", "value" ] Json.Decode.string)
        (Json.Decode.at [ "type" ] Type.inputTypeDecoder)


toRequiredVariables : List VariableDefinition -> List VariableDefinition
toRequiredVariables variableDefinitions =
    variableDefinitions
        |> List.filter isRequired


isRequired : VariableDefinition -> Bool
isRequired def =
    case def.type_ of
        Type.NonNull _ ->
            True

        _ ->
            False
