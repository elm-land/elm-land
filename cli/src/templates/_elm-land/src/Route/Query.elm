module Route.Query exposing (fromUrl, toString)

import Dict exposing (Dict)
import Url exposing (Url)
import Url.Parser exposing (query)


fromUrl : Url -> Dict String String
fromUrl url =
    case url.query of
        Nothing ->
            Dict.empty

        Just query ->
            if String.isEmpty query then
                Dict.empty

            else
                let
                    decode val =
                        Url.percentDecode val
                            |> Maybe.withDefault val
                in
                query
                    |> String.split "&"
                    |> List.filterMap
                        (String.split "="
                            >> (\eq ->
                                    Maybe.map2 Tuple.pair
                                        (List.head eq)
                                        (eq |> List.drop 1 |> List.head |> Maybe.withDefault "" |> Just)
                               )
                        )
                    |> List.map (Tuple.mapBoth decode decode)
                    |> Dict.fromList


toString : Dict String String -> Maybe String
toString query =
    if Dict.isEmpty query then
        Nothing

    else
        Dict.toList query
            |> List.map
                (\( key, value ) ->
                    String.join "="
                        [ Url.percentEncode key
                        , Url.percentEncode value
                        ]
                )
            |> String.join "&"
            |> String.append "?"
            |> Just
