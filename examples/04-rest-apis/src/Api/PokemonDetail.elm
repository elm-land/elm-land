module Api.PokemonDetail exposing (Pokemon, get)

import Http
import Json.Decode


type alias Pokemon =
    { name : String
    , pokedexId : Int
    , spriteUrl : String
    , types : List String
    }


get :
    { name : String
    , onResponse : Result Http.Error Pokemon -> msg
    }
    -> Cmd msg
get options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon/" ++ options.name
        , expect = Http.expectJson options.onResponse decoder
        }



-- JSON DECODERS


decoder : Json.Decode.Decoder Pokemon
decoder =
    Json.Decode.map4 Pokemon
        nameFieldDecoder
        pokedexIdFieldDecoder
        spriteUrlFieldDecoder
        typesFieldDecoder


nameFieldDecoder : Json.Decode.Decoder String
nameFieldDecoder =
    Json.Decode.field "name" Json.Decode.string


pokedexIdFieldDecoder : Json.Decode.Decoder Int
pokedexIdFieldDecoder =
    Json.Decode.field "order" Json.Decode.int


spriteUrlFieldDecoder : Json.Decode.Decoder String
spriteUrlFieldDecoder =
    Json.Decode.at
        [ "sprites", "other", "official-artwork", "front_default" ]
        Json.Decode.string


typesFieldDecoder : Json.Decode.Decoder (List String)
typesFieldDecoder =
    Json.Decode.field "types" (Json.Decode.list pokemonTypeDecoder)


pokemonTypeDecoder : Json.Decode.Decoder String
pokemonTypeDecoder =
    Json.Decode.at [ "type", "name" ] Json.Decode.string
