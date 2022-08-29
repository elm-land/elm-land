module Api.PokemonList exposing (getFirst150)

import Http
import Json.Decode


getFirst150 :
    { onResponse : Result Http.Error (List Pokemon) -> msg
    }
    -> Cmd msg
getFirst150 options =
    Http.get
        { url = "http://localhost:5000/api/v2/pokemon?limit=150"
        , expect = Http.expectJson options.onResponse decoder
        }


decoder : Json.Decode.Decoder (List Pokemon)
decoder =
    Json.Decode.field "results" (Json.Decode.list pokemonDecoder)


type alias Pokemon =
    { name : String
    }


pokemonDecoder : Json.Decode.Decoder Pokemon
pokemonDecoder =
    Json.Decode.map Pokemon
        (Json.Decode.field "name" Json.Decode.string)
