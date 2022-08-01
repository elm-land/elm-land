module Api.Pokemon exposing (Pokemon, getAll)

import Api
import Http
import Json.Decode


type alias Pokemon =
    { name : String
    }


getAll : { onResponse : Api.Data (List Pokemon) -> msg } -> Cmd msg
getAll options =
    Api.get
        { url = "https://pokeapi.co/api/v2/pokemon?limit=150"
        , onResponse = options.onResponse
        , decoder = Json.Decode.field "results" pokemonListDecoder
        }


pokemonListDecoder : Json.Decode.Decoder (List Pokemon)
pokemonListDecoder =
    Json.Decode.list pokemonDecoder


pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map Pokemon
        (Json.Decode.field "name" Json.Decode.string)
