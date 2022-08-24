module Domain.PokemonType exposing
    ( PokemonType, decoder
    , viewTags
    )

{-|

@docs PokemonType, decoder

@docs viewTags

-}

import Html exposing (Html)
import Html.Attributes exposing (class)
import Json.Decode


type PokemonType
    = Normal
    | Fighting
    | Flying
    | Poison
    | Ground
    | Rock
    | Bug
    | Ghost
    | Fire
    | Water
    | Grass
    | Electric
    | Psychic
    | Ice
    | Steel
    | Dragon
    | Dark
    | Fairy
    | Shadow
    | Unknown



-- DECODING FROM JSON


decoder : Json.Decode.Decoder PokemonType
decoder =
    Json.Decode.at [ "type", "name" ] Json.Decode.string
        |> Json.Decode.andThen fromStringToPokemonType


fromStringToPokemonType : String -> Json.Decode.Decoder PokemonType
fromStringToPokemonType nameOfType =
    case nameOfType of
        "normal" ->
            Json.Decode.succeed Normal

        "fighting" ->
            Json.Decode.succeed Fighting

        "flying" ->
            Json.Decode.succeed Flying

        "poison" ->
            Json.Decode.succeed Poison

        "ground" ->
            Json.Decode.succeed Ground

        "rock" ->
            Json.Decode.succeed Rock

        "bug" ->
            Json.Decode.succeed Bug

        "ghost" ->
            Json.Decode.succeed Ghost

        "fire" ->
            Json.Decode.succeed Fire

        "water" ->
            Json.Decode.succeed Water

        "grass" ->
            Json.Decode.succeed Grass

        "electric" ->
            Json.Decode.succeed Electric

        "psychic" ->
            Json.Decode.succeed Psychic

        "ice" ->
            Json.Decode.succeed Ice

        "steel" ->
            Json.Decode.succeed Steel

        "dragon" ->
            Json.Decode.succeed Dragon

        "dark" ->
            Json.Decode.succeed Dark

        "fairy" ->
            Json.Decode.succeed Fairy

        "shadow" ->
            Json.Decode.succeed Shadow

        "unknown" ->
            Json.Decode.succeed Unknown

        _ ->
            Json.Decode.fail ("Did not recognize pokemon type: " ++ nameOfType)



-- VIEW


viewTags : List PokemonType -> Html msg
viewTags pokemonTypes =
    Html.div [ class "tags is-centered py-4" ] (List.map viewTag pokemonTypes)


viewTag : PokemonType -> Html msg
viewTag pokemonType =
    Html.span [ class "tag" ] [ Html.text (toLabel pokemonType) ]


toLabel : PokemonType -> String
toLabel pokemonType =
    case pokemonType of
        Normal ->
            "Normal"

        Fighting ->
            "Fighting"

        Flying ->
            "Flying"

        Poison ->
            "Poison"

        Ground ->
            "Ground"

        Rock ->
            "Rock"

        Bug ->
            "Bug"

        Ghost ->
            "Ghost"

        Fire ->
            "Fire"

        Water ->
            "Water"

        Grass ->
            "Grass"

        Electric ->
            "Electric"

        Psychic ->
            "Psychic"

        Ice ->
            "Ice"

        Steel ->
            "Steel"

        Dragon ->
            "Dragon"

        Dark ->
            "Dark"

        Fairy ->
            "Fairy"

        Shadow ->
            "Shadow"

        Unknown ->
            "Unknown"
