module Api.PokemonDetail exposing (Pokemon, get)

import Api
import Domain.PokemonType exposing (PokemonType)
import Http
import Json.Decode


type alias Pokemon =
    { name : String
    , number : Int
    , imageUrl : String
    , types : List PokemonType
    }


get : { name : String, onResponse : Api.Data Pokemon -> msg } -> Cmd msg
get options =
    Api.get
        { url = "http://localhost:5000/api/v2/pokemon/" ++ options.name
        , onResponse = options.onResponse
        , decoder = pokemonDecoder
        }


pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map4 Pokemon
        (Json.Decode.field "name" Json.Decode.string)
        (Json.Decode.field "order" Json.Decode.int)
        (Json.Decode.at [ "sprites", "other", "official-artwork", "front_default" ] Json.Decode.string)
        (Json.Decode.field "types" (Json.Decode.list Domain.PokemonType.decoder))
